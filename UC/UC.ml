(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* NOTE: Use Eliom_common.default_process_scope to ensure that each session is only available in one tab. Bad things could happen if the user could play the game in two tabs? *)

(* TODO: Populate user_info with all information *)
(* TODO: Replace all Facebook functions with calls to the same functions in Facebook.ml *)
(* TODO: Add user photo to header_navbar_skeleton *)

(* NOTE: All functions outside of services are designed to take a user, not a user Lwt.t *)

open Eliom_lib
open Eliom_content
open Eliom_parameter
open Html5.D

(* Get string from string option *)
let string_of_option so =
  match so with
  | Some s -> s
  | None -> ""


(* Link to Facebook sign in with redirect *)
(* TODO: Request permissions for public_profile, user_friends, picture *)
let facebook_redirect_address = 
  Xml.uri_of_string ("https://www.facebook.com/dialog/oauth?client_id=" ^ 
                     Facebook.facebook_app_id ^ "&redirect_uri=http://localhost:8080/gameplay" ^
                     "&scope=public_profile"(*user_photos,user_friends,publish_actions*))


module UC_app =
  Eliom_registration.App (
    struct
      let application_name = "UC"
    end)


(* Login page service *)
let login_page_service =
  Eliom_service.App.service ~path:["login"] ~get_params:Eliom_parameter.unit ()


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


(* Create an image from an external link *)
let ext_img image_link description =
  img ~alt:description ~src:(Xml.uri_of_string image_link) ()


(* facebook login button *)
let facebook_login_button =
  let open Html5.F in
  div ~a:[a_class ["btn-group"]]
  [Raw.a ~a:[a_class ["btn btn-primary"]; a_href facebook_redirect_address]
   [i ~a:[a_class ["fa fa-facebook"]] [pcdata "  | Sign in with Facebook"] (* /i *)
   ] (* /a *)
  ] (* /div *)


(* Header Navbar html skeleton *)
(* unit -> html_stuff Lwt.t *)
(* TODO: get the name in the top right corner to show up as white *)
(* TODO: I have a photo, it is showing up, but not at the same time as the words *)
let header_navbar_skeleton (u : Facebook.user) =
  let open Facebook in
  let login_button_or_welcome =
      match (u.verified, u.profile_photo) with
      | (Some true, Some photo) ->
          (li ~a:[a_class ["user_name_and_photo"]]
           [p ~a:[a_class ["user_name"]]
            [pcdata ((string_of_option u.first_name) ^ " " ^ (string_of_option u.last_name) ^ "  ")];
            ext_img photo "Facebook Profile Picture"]
          )
          (*
          (li [ext_img photo "Main Profile Picture"];
           li
           [h2 [pcdata ((string_of_option u.first_name) ^ " " ^ (string_of_option u.last_name))]
           ] (* /li *)
          )
          *)
      | (Some true, None) ->
          (li
           [h2 [pcdata ((string_of_option u.first_name) ^ " " ^ (string_of_option u.last_name))]
           ] (* /li *)
          )
      | (_, _) -> (li [facebook_login_button])
  in
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [];
    ul ~a:[a_class ["nav navbar-nav navbar-right"; "fb_login"]]
    [login_button_or_welcome
    ] (* /ul *)
   ] (* /div *)
  ] (* /div *)


(* Welcome message - displayed when user first logs in and is verified *)
let welcome_message (u : Facebook.user) =
  let open Facebook in
  match u.verified with
  | Some true -> ("Welcome " ^ (string_of_option u.first_name) ^ " " ^
                  (string_of_option u.last_name) ^ "!")
  | _ -> "You are not logged in or have not been verified!"


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
let main =
  Eliom_registration.Html5.register_service
    ~path:["main"]
    ~get_params:unit
    (fun () () ->
      (* Kick off the thread *)
      Eliom_reference.get Facebook.user_info
      >>= fun user ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Unsportsmanlike Conduct"
           ~css:[["css"; "UC.css"]]
           ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
           Html5.F.(
           body
           [header_navbar_skeleton user;
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
          [(*header_navbar_skeleton;*)
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
      (* string -> user Lwt.t *) (* Kick off the thread *)
      Facebook.verify_user fb_code
      (* user -> eref -> unit Lwt.t *) (* Set user_info *)
      >>= fun u -> Eliom_reference.set Facebook.user_info u
      (* unit -> unit Lwt.t *) (* Update user_info *)
      >>= fun () -> Facebook.update_user_info ()
      (* unit -> unit Lwt.t *) (* Update the users photo *)
      >>= fun () -> Facebook.update_profile_photo ()
      (* unit -> Facebook.user Lwt.t *)
      >>= fun () -> Eliom_reference.get Facebook.user_info
      (* Facebook.user -> html_stuff Lwt.t *)
      >>= fun user ->
      Lwt.return
        (*Html5.D.(html*)
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Play Ball!"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
          Html5.F.(
           body
           [header_navbar_skeleton user;
            div ~a:[a_class ["container"; "margin_top_50px"]]
            [div ~a:[a_class ["page-header"]]
             [h1 [pcdata (welcome_message user)];
              h1 [pcdata ("access_token = " ^ (string_of_option user.access_token))]
             ] (* /div *)
            ] (* /div *)
           ] (* /body *)
          )
        )
    )
