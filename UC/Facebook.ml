(* Facebook API functions *)
(* by Thomas Brittain *)


let facebook_app_id = "1432703690354746"
let app_secret = "01a6334b2c71020d23b16a022d1c316b"


(* WTF OCaml?! Why do you do this to me? *)
let (>>=) = Lwt.bind


(* User type *)
type user = {first_name : string option;
             last_name : string option;
             uc_username : string option;
             email_address : string option;
             access_token : string option;
             expires : int option;
             verified : bool option}


(* Default verification_result to seed the user_info ref *)
let initial_user_info = {first_name = None; last_name = None; uc_username = None;
                         email_address = None; access_token = None; expires = None; verified = None}


(* Refs for user session data - initialize with all fields = None *)
let user_info =
  Eliom_reference.eref ~scope:Eliom_common.default_process_scope
                       ~secure:true
                       initial_user_info



(* Handmade Core.Core_string.split_on_chars b/c core breaks in Ocsigen *)
let split_string_on in_string ~on =
  (* Split the string into a list of its individual characters, as strings not characters *)
  let list_of_string s = 
    let rec build_string_list in_string out_string_list =
      match String.length in_string with
      | 0 -> List.rev out_string_list
      | _ -> build_string_list (String.sub in_string 1 ((String.length in_string) -1))
                               ((String.sub in_string 0 1) :: out_string_list)
    in
    build_string_list s []
  in  
  (* Then concatenate and split into another list based on the chars chosen *)
  let build_final_string_list sl ~split_on =
    let rec f curr_string curr_list remaining =
      match List.length remaining with
      | 0 -> List.rev (if curr_string = "" then curr_list else (curr_string :: curr_list))
      | _ -> if List.mem (List.hd remaining) split_on
             then f "" (curr_string :: curr_list) (List.tl remaining)
             else f (curr_string ^ (List.hd remaining)) curr_list (List.tl remaining)
    in
    f "" [] sl
  in
  build_final_string_list (list_of_string in_string) ~split_on:on


(* Verify a Facebook user and update access_token, expires & verified fields*)
(* verify_user : string -> user Lwt.t *)
let verify_user code_parameter =
  let redirect_uri = "http://localhost:8080/gameplay" in
  let o_auth_endpoint =
    Uri.of_string
     (
       "https://graph.facebook.com/oauth/access_token?" ^ "client_id=" ^ facebook_app_id ^
       "&redirect_uri=" ^ redirect_uri ^ "&client_secret=" ^ app_secret ^ "&code=" ^ code_parameter
     )
   in
   (* Uri.t -> (Response.t * Cohttp_lwt_body.t) Lwt.t *)
   Cohttp_lwt_unix.Client.get o_auth_endpoint
   (* (Response.t * Cohttp_lwt_body.t) -> string Cohttp_lwt_unix_net.io Lwt.t *)
   >>= fun (a, b) -> b |> Cohttp_lwt_body.to_string
   >>= fun s -> split_string_on s ~on:["="; "&"] |> Lwt.return
   >>= fun l ->
     match (l, List.mem "access_token" l) with
     | (l, true) -> {first_name = None; last_name = None; uc_username = None;
                     email_address = None; access_token = Some (List.nth l 1);
                     expires = Some (List.nth l 3 |> int_of_string); verified = Some true}
                    |> Lwt.return
     | (_, false) -> {first_name = None; last_name = None; uc_username = None;
                      email_address = None; access_token = None; expires = None;
                      verified = Some false}
                    |> Lwt.return


(* Get the users info from the graph api node /me and populate the fields in user_info *)
(* Note: Can't use Eliom_reference.modify b/c the user reference scope is default_process_scope *)
(* update_user_info : unit -> unit Lwt.t *)
let update_user_info () =
  Eliom_reference.get user_info
  >>= fun u -> match u.access_token with
  | Some acc_tkn ->
      let me_uri = Uri.of_string ("https://graph.facebook.com/me?access_token=" ^ acc_tkn) in
      let open Yojson.Basic.Util in
      Cohttp_lwt_unix.Client.get me_uri
      >>= fun (a, b) -> b |> Cohttp_lwt_body.to_string
      >>= fun s -> Yojson.Basic.from_string s |> Lwt.return
      >>= fun json_string -> 
        (* TODO: Get other fields from facebook and add them here *)
        let fn = json_string |> member "first_name" |> to_string in
        let ln = json_string |> member "last_name" |> to_string in
        Eliom_reference.set user_info
                            {first_name = Some fn; last_name = Some ln;
                             uc_username = u.uc_username;
                             email_address = u.email_address;
                             access_token = u.access_token;
                             expires = u.expires; verified = u.verified}
      >>= fun _ -> Lwt.return ()
  | None -> Lwt.return ()
