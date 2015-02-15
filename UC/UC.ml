(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* NOTE: To use a .ml file insead of a .eliom file with a .eilom file removed from the directory *)
(* modify Makefile.options to make sure that hte .ml file is in the SERVER_FILES array *)

open Eliom_lib
open Eliom_content
open Html5.D

module UC_app =
  Eliom_registration.App (
    struct
      let application_name = "UC"
    end)

(* Main page service *)
let main_page_service =
  Eliom_service.App.service ~path:["main"] ~get_params:Eliom_parameter.unit ()

(* Login page service *)
(*
let gameplay_page_service =
  Eliom_service.App.service ~path:["gameplay"] ~get_params:Eliom_parameter.unit ()
  *)

(* create a link *)
let link_to ~address ~content =
  Html5.F.Raw.a ~a:[a_href (Xml.uri_of_string address)] content

(* Bootstrap CDN link *)
let bootstrap_cdn_link =
  let cdn_link = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" in
  link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
  ()

(* Login Button *)
let login =
  link_to 
    ~address:"login"
    ~content:([Raw.span ~a:[a_class ["glyphicon glyphicon-log-in"]] [pcdata " Login via Facebook"]])

(* Header Navbar html skeleton *)
let header_navbar_skeleton =
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [pcdata "link goes here"];
    div
    [ul ~a:[a_class ["nav navbar-nav navbar-right"]]
     [li [login]] (* /ul *)
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

let () =
  UC_app.register
    ~service:main_page_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Unsportsmanlike Conduct"
           ~css:[["css";"UC.css"]]
           ~other_head:[bootstrap_cdn_link]
           Html5.F.(
           body
           [header_navbar_skeleton;
            div ~a:[a_class ["container"; "margin_top_50px"; "padding_top_50px"]]
            [div ~a:[a_class ["jumbotron"]]
             [h1 [pcdata "Unsportsmanlike Conduct"]];
              p [pcdata "Sub title goes here"];
            ]; (* /div *)
            div ~a:[a_class ["row"]]
            [div ~a:[a_class ["col-md-3"]] [pcdata "welcome"]
            ]; (* /div *)
            footer_navbar_skeleton
           ](* /body *))))
