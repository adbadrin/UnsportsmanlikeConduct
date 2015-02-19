(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* NOTE: To use a .ml file insead of a .eliom file with a .eilom file removed from the directory *)
(* modify Makefile.options to make sure that hte .ml file is in the SERVER_FILES array *)

open Eliom_lib
open Eliom_content
open Eliom_parameter
open Html5.D


(* Facebook App Id for Unsportsmanlike Conduct *)
let facebook_app_id = "1432703690354746"


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


(* Login Button *)
let login =
  link_to 
    ~address:"login" 
    ~content:([Raw.span ~a:[a_class ["glyphicon glyphicon-log-in"]] [pcdata " Login with Facebook"]])


(* facebook login button *)
let facebook_login =
  Html5.F.Raw.a 
    ~a:[a_href (Xml.uri_of_string ("https://www.facebook.com/dialog/oauth?client_id=" ^ 
                                   facebook_app_id ^ "&redirect_uri=http://localhost:8080/gameplay"))]
      [pcdata "Login with Facebook"]

let facebook_login_2 =
  let open Html5.F in
  div ~a:[a_class ["social-buttons"]]
  [Raw.a ~a:[a_class ["btn btn-block btn-social btn-facebook"];
                     a_href (Xml.uri_of_string ("https://www.facebook.com"))]
   [i ~a:[a_class ["fa fa-facebook fa-lg"]] [pcdata " Sign in with Facebook"]
   ] (* /a *)
  ] (* /div *)


(* Header Navbar html skeleton *)
let header_navbar_skeleton =
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [];
    div
    [ul ~a:[a_class ["nav navbar-nav navbar-right"]]
     [li [facebook_login_2]] (* /ul *)
    ] (* /div *)
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
          ~other_head:[bootstrap_cdn_link]
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


(* Register gameplay_service *)
let gameplay =
  Eliom_registration.Html5.register_service
    ~path:["gameplay"]
    ~get_params:(string "code")
    (fun fb_code () ->
      Lwt.return
        (*Html5.D.(html*)
        (Eliom_tools.F.html
          ~title:"Unsportsmanlike Conduct - Play Ball!"
          ~css:[["css"; "UC.css"]]
          ~other_head:[bootstrap_cdn_link]
          Html5.F.(
           body
           [header_navbar_skeleton;
            div ~a:[a_class ["container"; "margin_top_50px"]]
            [div ~a:[a_class ["page-header"]]
             [h1 [pcdata ("The code sent from facebook is: " ^ fb_code)]
             ] (* /div *)
            ] (* /div *)
           ] (* /body *)
          )
        )
    )
