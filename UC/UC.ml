(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* NOTE: To use a .ml file insead of a .eliom file with a .eilom file removed from the directory *)
(* modify Makefile.options to make sure that hte .ml file is in the SERVER_FILES array *)

(* NOTE: Use Eliom_common.default_process_scope to ensure that each session is only available in one tab. Bad things could happen if the user could play the game in two tabs? *)

open Eliom_lib
open Eliom_content
open Eliom_parameter
open Html5.D

let facebook_app_id = "1432703690354746"
let app_secret = "01a6334b2c71020d23b16a022d1c316b"

(* User type *)
type user = {first_name : string option; last_name : string option; uc_username : string option;
             email_address : string option; access_token : string option; expires : int option}

(* Facebook user verification type *)
type verification_result = Success of user | Failure of user

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



(* Verify a Facebook user *)
(* TODO: Remove the use of core from this function. It seems to be causing problems. *)
(* Error: '-type-conv' option disabled but some packages require the type_conv syntax to be loaded. *)
(* verify_user : string -> verification_result Lwt.t *)
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
     | (l, true) -> Success {first_name = None; last_name = None; uc_username = None;
                             email_address = None; access_token = Some (List.nth l 1);
                             expires = Some (List.nth l 3 |> int_of_string)}
                    |> Lwt.return
     | (_, false) -> Failure {first_name = None; last_name = None; uc_username = None;
                              email_address = None; access_token = None; expires = None}
                     |> Lwt.return


(* TEST - Delete this later *)
let dummy_verify () =
  Success {first_name = Some "Jimmy"; last_name = Some "Dean"; uc_username = Some "JimmyDeanSausage";
           email_address = Some "jimmydean@jimmydeansausage.com"; access_token = Some "69";
           expires = Some 69}

(* Refs for user session data - initialize with all fields = None *)
let user_info =
  Eliom_reference.eref ~scope:Eliom_common.default_process_scope
                       ~secure:true
                       (
                         Failure {first_name = None; last_name = None; uc_username = None;
                                  email_address = None; access_token = None; expires = None}
                       )


(* Facebook App Id for Unsportsmanlike Conduct *)
let facebook_app_id = "1432703690354746"


(* Link to Facebook sign in with redirect *)
let facebook_redirect_address = 
  Xml.uri_of_string ("https://www.facebook.com/dialog/oauth?client_id=" ^ 
                     facebook_app_id ^ "&redirect_uri=http://localhost:8080/gameplay")


module UC_app =
  Eliom_registration.App (
    struct
      let application_name = "UC"
    end)


(* Main page service *)
let main_page_service =
  Eliom_service.App.service ~path:["main"] ~get_params:Eliom_parameter.unit ()


(* Login page service *)
let login_page_service =
  Eliom_service.App.service ~path:["login"] ~get_params:Eliom_parameter.unit ()


(* Gameplay page service *)
(*
let gameplay_page_service =
  Eliom_service.App.service ~path:["gameplay"] ~get_params:(string "code")
*)

(* create a link *)
let link_to ~address ~content =
  Html5.F.Raw.a ~a:[a_href (Xml.uri_of_string address)] content


(* Bootstrap CDN link *)
let bootstrap_cdn_link =
  let cdn_link = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" in
  link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
  ()


(* FontAwesome CDN link *)
let font_awesome_cdn_link =
  let cdn_link = "//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.min.css" in
  link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
  ()


(* facebook login button *)
let facebook_login_button =
  let open Html5.F in
  div ~a:[a_class ["btn-group"]]
  [Raw.a ~a:[a_class ["btn btn-primary"]; a_href facebook_redirect_address]
   [i ~a:[a_class ["fa fa-facebook"]] [pcdata "  | Sign in with Facebook"] (* /i *)
   ] (* /a *)
  ] (* /div *)


(* Header Navbar html skeleton *)
let header_navbar_skeleton =
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [];
    (*div*)
    (*[*)ul ~a:[a_class ["nav navbar-nav navbar-right"; "fb_login"]]
     [li [facebook_login_button]] (* /ul *)
    (*]*) (* /div *)
   ] (* /div *)
  ] (* /div *)


(* Footer Navbar html skeleton *)
(* TODO: Add padding to the top of this navbar. It has overlay like the header navbar *)
let footer_navbar_skeleton =
  nav ~a:[a_class ["navbar navbar-fixed-bottom"]]
    [div ~a:[a_class ["container-fluid"]]
     [div
      [ul ~a:[a_class ["nav navbar-nav navbar-center"]]
       [li [pcdata "Contact goes here"];
       ] (* /ul *)
      ] (* /div *)
     ] (* /div *)
    ] (* /nav *)


let subtitle =
  "Don't play with yourself, play with your friends!"


(* Placeholder for next page *)
let display_user_info = Eliom_registration.Html5.register_service
  ~path:["display"]
  ~get_params:Eliom_parameter.any
  (fun l () ->
    Lwt.return
      (Eliom_tools.F.html
        ~title:"display_page"
        ~css:[["css"; "UC.css"]]
        Html5.F.(
          body [h1 [pcdata "This is the service generated by the login page"]] 
        )
      )
  )


(* Login form *)
let login_form =
  get_form display_user_info
    (fun () ->
      [div ~a:[a_class ["form-group"]]
       [div ~a:[a_class ["input-group"]]
        [Raw.span ~a:[a_class ["input-group-addon"]]
         [Raw.span ~a:[a_class ["glyphicon glyphicon-envelope"]] []
         ]; (* /span *)
         raw_input ~a:[a_class ["form-control"]; a_placeholder "Email Address"]
                   ~input_type:`Text ~name:"email_address" ()
        ] (* /div *)
       ]; (* /div *)
       div ~a:[a_class ["form-group"]]
       [div ~a:[a_class ["input-group"]]
        [Raw.span ~a:[a_class ["input-group-addon"]]
         [Raw.span ~a:[a_class ["glyphicon glyphicon-lock"]] []
         ]; (* /span *)
         raw_input ~a:[a_class ["form-control"]; a_placeholder "Password"]
                   ~input_type:`Password ~name:"password" ()
        ] (* /div *)
       ]; (* /div *)
      ]
    )


(* Container for login_form *)
let login_form_container =
  div ~a:[a_class ["container"]]
  [div ~a:[a_class ["col-md-4 col-md-offset-4"]]
   [div ~a:[a_class ["panel panel-default"]]
    [div ~a:[a_class ["panel-body"]]
     [login_form
     ] (* /div *)
    ] (* /div *)
   ] (* /div *)
  ] (* /div *)


(* Register main_page_service *)
let () =
  UC_app.register
    ~service:main_page_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Unsportsmanlike Conduct"
           ~css:[["css"; "UC.css"]]
           ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
           Html5.F.(
           body
           [header_navbar_skeleton;
            div ~a:[a_class ["container"; "margin_top_50px"; "padding_top_50px"]]
            [div ~a:[a_class ["jumbotron"]]
             [h1 [pcdata "Unsportsmanlike Conduct"]];
              p [pcdata subtitle]
            ]; (* /div *)
            div ~a:[a_class ["row"]]
            [div ~a:[a_class ["col-md-3"]] [pcdata "welcome"]
            ]; (* /div *)
            footer_navbar_skeleton
           ](* /body *))))


(* Register login_page_service *)
let () =
  UC_app.register
    ~service:login_page_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Register"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
          Html5.F.(
          body
          [header_navbar_skeleton;
           div ~a:[a_class ["container"; "margin_top_50px"]]
           [div ~a:[a_class ["page-header"]]
            [h1 [pcdata "Login"]
            ] (* /div *)
           ]; (* /div *)
           login_form_container
          ] (* /body *)
          )
        )
    )


(* TODO: Get eliom to recognize Facebook.ml and then use Facebook.verify_user to check that the *)
(*       access_token and expires parameteres are being passed properly when verification both *)
(*       passes and fails *)
(* Register gameplay_service *)
let gameplay =
  Eliom_registration.Html5.register_service
    ~path:["gameplay"]
    ~get_params:(string "code")
    (fun fb_code () ->
      let f x =
        match x with
        | Some x -> x
        | None -> "Empty_String"
      in
      let g x =
        match x with
        | Some x -> string_of_int x
        | None -> "Empty_String_of_Int"
      in
      let test = match dummy_verify () with
      | Success x -> ("Welcome " ^ (f x.first_name) ^ " " ^ (f x.last_name) ^ "!") (*"test passed"*)
      | Failure x -> "you should not see this!"
      in
      let access_token = "access_token" in
      let expires = 1234321 in
      (* eref -> string Lwt.t *)
      let get_test_ref user_ref =
        Eliom_reference.get user_ref 
        >>= fun vr ->
              match vr with
              | Success x -> ("Welcome " ^ (f x.first_name) ^ " " ^ (f x.last_name) ^ "!" ^
                              "\nYour access token is " ^ (f x.access_token) ^
                              " and your expires = " ^ (g x.expires) ^ "!")
                             |> Lwt.return
              | Failure x -> "FAIL!" |> Lwt.return
      in
      (* Kick off the thread *)
      (* string -> verification_result Lwt.t *)
      verify_user fb_code
      (* verification_result -> eref -> unit Lwt.t *)
      >>= fun u -> Eliom_reference.set user_info u (* Set the user_info *)
      (* unit -> eref -> string Lwt.t *)
      >>= fun () -> get_test_ref user_info
      (* string -> html_stuff Lwt.t *)
      >>= fun test_string ->
      Lwt.return
        (*Html5.D.(html*)
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Play Ball!"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
          Html5.F.(
           body
           [header_navbar_skeleton;
            div ~a:[a_class ["container"; "margin_top_50px"]]
            [div ~a:[a_class ["page-header"]]
             [h1 [pcdata ("The code sent from facebook is: " ^ fb_code)];
              h1 [pcdata ("The access token is: " ^ access_token)];
              h1 [pcdata ("The time to expiration is: " ^ (string_of_int expires))];
              h1 [pcdata ("Testing dummy_verify --- " ^ test)];
              h1 [pcdata ("Testing Facebook.verify_user_2 --- " ^ test_string)]
             ] (* /div *)
            ] (* /div *)
           ] (* /body *)
          )
        )
    )
