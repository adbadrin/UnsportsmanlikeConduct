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
             profile_photo : string option;
             access_token : string option;
             expires : int option;
             verified : bool option}


(* Permissions type - true = granted, false = not granted*)
type permissions = {public_profile : bool option;
                    photo : string option;
                    user_photos : bool option;
                    friendlist_id: string option}

(* Friends list type *)
type friends_list = (string * int) list option


(* Default verification_result to seed the user_info ref *)
let initial_user_info = {first_name = None; last_name = None; uc_username = None;
                         email_address = None; profile_photo = None; access_token = None;
                         expires = None; verified = None}


(* Default permissions to seed the user_permissions ref *)
let initial_permissions = {public_profile = None; photo = None; user_photos = None;
                           friendlist_id = None}


(* Refs for user session data *)
(*
let user_info =
  Eliom_reference.eref ~scope:Eliom_common.default_process_scope
                       ~secure:true
                       initial_user_info


let user_permissions =
  Eliom_reference.eref ~scope:Eliom_common.default_process_scope
                       ~secure:true
                       initial_permissions
*)


(* Functions to update Eliom ref fields - this seems sloppy, there must be a better way to do this *)

(* update_public_profile : permissions eref -> bool option -> unit Lwt.t *)
let update_public_profile user_perms b_opt =
  Eliom_reference.get user_perms
  >>= fun up ->
    Eliom_reference.set user_perms
                        {public_profile = b_opt; photo = up.photo; user_photos = up.user_photos;
                         friendlist_id = up.friendlist_id}


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
                     email_address = None; profile_photo = None; access_token = Some (List.nth l 1);
                     expires = Some (List.nth l 3 |> int_of_string); verified = Some true}
                    |> Lwt.return
     | (_, false) -> {first_name = None; last_name = None; uc_username = None;
                      email_address = None; profile_photo = None; access_token = None;
                      expires = None; verified = Some false}
                    |> Lwt.return


(* Get the users info from the graph api node /me and populate the fields in user_info *)
(* Note: Can't use Eliom_reference.modify b/c the user reference scope is default_process_scope *)
(* update_user_info : user_info eref -> unit Lwt.t *)
let update_user_info u_info =
  Eliom_reference.get u_info
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
        Eliom_reference.set u_info
                            {first_name = Some fn; last_name = Some ln;
                             uc_username = u.uc_username;
                             email_address = u.email_address;
                             profile_photo = u.profile_photo;
                             access_token = u.access_token;
                             expires = u.expires; verified = u.verified}
      >>= fun _ -> Lwt.return ()
  | None -> Lwt.return ()


(* Update the users friends list *) 
(*
let update_friends_list u_info =
  Eliom_reference.get u_info
  >>= fun u -> match u.access_token with
  | Some acc_tkn ->
      let friends_list_uri =
        Uri.of_string ("https://graph.facebook.com/me/friends?access_token=" ^ acc_tkn)
      in
      let open Yojson.Basic.Util in
      Cohttp_lwt_unix.Client.get friends_list_uri
      >>= fun (a, b) -> b |> Cohttp_lwt_body.to_string
      >>= fun s -> Yojson.Basic.from_string s |> Lwt.return
      >>= fun json_assoc ->
        json_assoc |> member "data" |>
  | None -> Lwt.return "unit"
  *)


(* Update the user photo in the permissions *)
(* update_profile_photo : permissions eref -> unit Lwt.t *)
let update_profile_photo u_info user_perms =
  let update_photo new_photo =
    Eliom_reference.get user_perms
    >>= fun up ->
      Eliom_reference.set user_perms
                          {public_profile = up.public_profile; photo = Some new_photo;
                           user_photos = up.user_photos; friendlist_id = up.friendlist_id}
    >>= fun () -> Eliom_reference.get u_info
    >>= fun u ->
      Eliom_reference.set u_info
                          {first_name = u.first_name; last_name = u.last_name;
                           uc_username = u.uc_username; email_address = u.email_address;
                           profile_photo = Some new_photo; access_token = u.access_token;
                           expires = u.expires; verified = u.verified}
  in
  Eliom_reference.get u_info
  >>= fun u -> match u.access_token with
  | Some acc_tkn ->
      let photo_uri =
        Uri.of_string ("https://graph.facebook.com/me/picture?redirect=false&access_token=" ^ acc_tkn)
      in
      let open Yojson.Basic.Util in
      Cohttp_lwt_unix.Client.get photo_uri
      >>= fun (a, b) -> b |> Cohttp_lwt_body.to_string
      >>= fun s -> Yojson.Basic.from_string s |> Lwt.return
      >>= fun json ->
        let photo_string =
          try
            member "data" json |> member "url" |> to_string
          with _ -> ""
        in
        update_photo photo_string
  | None -> Lwt.return ()

(* Update the users permissions *)
(* update_user_permissions : user eref -> unit Lwt.t *)
let update_user_permissions u_info user_perms =
  Eliom_reference.get u_info
  >>= fun u -> match u.access_token with
  | Some acc_tkn ->
      let perm_uri =
        Uri.of_string ("https://graph.facebook.com/me/permissions?access_token=" ^ acc_tkn)
      in
      let open Yojson.Basic.Util in
      Cohttp_lwt_unix.Client.get perm_uri
      >>= fun (a, b) -> b |> Cohttp_lwt_body.to_string
      >>= fun s -> Yojson.Basic.from_string s |> Lwt.return
      >>= fun json -> member "data" json |> index 0 |> Lwt.return
      >>= fun json ->
        (* TODO: add the rest of the necessary permissions *)
        let pub_prof_perm =
          try 
            if (json |> member "permission" |> to_string) = "public_profile" 
            && (json |> member "status" |> to_string) = "granted"
            then Some true else None
          with _ ->
            None
        in
        update_public_profile user_perms pub_prof_perm
  | None -> Lwt.return ()
