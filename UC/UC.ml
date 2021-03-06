(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* NOTE: Use Eliom_common.default_process_scope to ensure that each session is only available in one tab. Bad things could happen if the user could play the game in two tabs? *)

(* TODO: Populate user_info with all information *)
(* TODO: Replace all Facebook functions with calls to the same functions in Facebook.ml *)
(* TODO: Maybe need to move user info ref to this module. User is logged out when going to new_game after already being logged in. I think that the ref is not being stored properly and the data is being lost since the ref is in another module. *)

(* NOTE: All functions outside of services are designed to take a user, not a user Lwt.t *)

open Eliom_lib
open Eliom_content
open Eliom_parameter
open Html5.D


(* Refs for user session data *)
let user_info =
  let open Facebook in
  Eliom_reference.eref ~scope:Eliom_common.default_group_scope
                       ~secure:true
                       {first_name = None; last_name = None; uc_username = None;
                        email_address = None; profile_photo = None; access_token = None;
                        expires = None; verified = None}


let user_permissions =
  let open Facebook in
  Eliom_reference.eref ~scope:Eliom_common.default_group_scope
                       ~secure:true
                       {public_profile = None; photo = None; user_photos = None;
                        friendlist_id = None}

(* Serivce creation *)
let new_game_service =
  Eliom_service.Http.service ~path:["new_game"] ~get_params:unit ()

let main_page_service =
  Eliom_service.Http.service ~path:["main"] ~get_params:unit ()


(* Get string from string option *)
let string_of_option so =
  match so with
  | Some s -> s
  | None -> ""


(* Get bool from bool option *)
let bool_of_option bo =
  match bo with
  | Some true -> true
  | _ -> false


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


(* Facebook login button *)
let facebook_login_button =
  let open Html5.F in
  div ~a:[a_class ["btn-group"]]
  [Raw.a ~a:[a_class ["btn btn-primary"]; a_href facebook_redirect_address]
   [i ~a:[a_class ["fa fa-facebook"]] [pcdata "  | Sign in with Facebook"] (* /i *)
   ] (* /a *)
  ] (* /div *)


(* Main page button *)
let main_page_button =
  let open Html5.F in
  div ~a:[a_class ["btn btn-default btn-lg"; "main_page"]]
  [a main_page_service [pcdata "Home"] ()
  ] (* /div *)


(* Start New Game button *)
let new_game_button =
  let open Html5.F in
  div ~a:[a_class ["btn btn-default btn-lg"; "main_page"]]
  [a new_game_service [pcdata "Start a New Game!"] ()
  ] (* /div *)


(* Header Navbar html skeleton *)
(* unit -> html_stuff Lwt.t *)
let header_navbar_skeleton (u : Facebook.user) =
  let open Facebook in
  let login_button_or_welcome =
      match (u.verified, u.profile_photo) with
      | (Some true, Some photo) ->
          (li ~a:[a_class ["user_name_and_photo"]]
           [p ~a:[a_class ["user_name"]]
            [pcdata ((string_of_option u.first_name) ^ " " ^ (string_of_option u.last_name) ^ "  ")];
             ext_img photo "Facebook Profile Picture"
           ]
          )
      | (Some true, None) ->
          (li
           [h2 [pcdata ((string_of_option u.first_name) ^ " " ^ (string_of_option u.last_name))]
           ] (* /li *)
          )
      | (_, _) -> (li [facebook_login_button])
  in
  let new_gm_btn = if (bool_of_option u.verified) then new_game_button else (pcdata "") in
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [];
    main_page_button;  (**)
    new_gm_btn;
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


(* New Game form *)
(* TODO: Need # players, # cards, Max time per player, penalty yards to win *)
let new_game_form =
  get_form display_user_info
    (fun () ->
      [
       div ~a:[a_class ["form-group"]]
       [div ~a:[a_class ["input-group"]]
        [Raw.span ~a:[a_class ["input-group-addon"]]
         [Raw.span ~a:[a_class ["glyphicon glyphicon-flag"]] []
         ]; (* /span *)
         raw_input ~a:[a_class ["form-control"]; a_placeholder "Game Name"]
                   ~input_type:`Text ~name:"email_address" ()
        ] (* /div *)
       ]; (* /div *)

       div ~a:[a_class ["btn-toolbar"]]
       [h4 ~a:[a_class ["num_of_players"]] [pcdata "Number of Players"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "3"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "4"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "5"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "6"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "7"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "8"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "9"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "10"];
       ];

       div ~a:[a_class ["btn-toolbar"]]
       [h4 ~a:[a_class ["num_of_players"]] [pcdata "Number of Cards"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "4"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "5"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "6"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "7"];
        div ~a:[a_class ["btn btn-default"]] [pcdata "8"];
       ];

      ]
    )


(* Container for new_game_form *)
let new_game_form_container =
  div ~a:[a_class ["container"]]
  [div ~a:[a_class ["col-md-4 col-md-offset-4"]]
   [div ~a:[a_class ["panel panel-default"]]
    [div ~a:[a_class ["panel-body"]]
     [new_game_form
     ] (* /div *)
    ] (* /div *)
   ] (* /div *)
  ] (* /div *)


(* Register main_page_service *)
let () =
  Eliom_registration.Html5.register
    ~service:main_page_service
    (fun () () ->
      (* Kick off the thread *)
      Eliom_reference.get user_info
      >>= fun user ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Unsportsmanlike Conduct"
           ~css:[["css"; "UC.css"]]
           ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
           Html5.F.(
           body ~a:[a_class ["transparent"]]
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


(* Register new_game_service *)
let () =
  Eliom_registration.Html5.register
    ~service:new_game_service
    (fun () () ->
      Eliom_reference.get user_info
      >>= fun user ->
      Lwt.return
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Start a New Game"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
          Html5.F.(
          body ~a:[a_class ["transparent"]]
          [header_navbar_skeleton user;
           div ~a:[a_class ["container"; "margin_top_50px"]]
           [div ~a:[a_class ["page-header"]]
            [h1 ~a:[a_class ["new_game"]] [pcdata "Start a New Game"];
             new_game_form_container
            ] (* /div *)
           ] (* /div *)
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
      >>= fun u -> Eliom_reference.set user_info u
      (* unit -> unit Lwt.t *) (* Update user_info *)
      >>= fun () -> Facebook.update_user_info user_info
      (* unit -> unit Lwt.t *) (* Update the users photo *)
      >>= fun () -> Facebook.update_profile_photo user_info user_permissions
      (* unit -> Facebook.user Lwt.t *)
      >>= fun () -> Eliom_reference.get user_info
      (* Facebook.user -> html_stuff Lwt.t *)
      >>= fun user ->
      Lwt.return
        (*Html5.D.(html*)
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Play Ball!"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
          Html5.F.(
           body ~a:[a_class ["transparent"]]
           [header_navbar_skeleton user;
            div ~a:[a_class ["container"; "margin_top_50px"]]
            [div ~a:[a_class ["page-header"; "new_game"]]
             [h1 [pcdata (welcome_message user)];
              h3 [pcdata "What would you like to do?"];
              new_game_button
             ] (* /div *)
            ] (* /div *)
           ] (* /body *)
          )
        )
    )
