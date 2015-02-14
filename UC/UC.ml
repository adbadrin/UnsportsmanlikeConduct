(* test by running "make test.byte" in the directory containing this file*)
(* the test on local host at "http://localhost:8080" *)

(* Bootstrap CDN link *)
let bootstrap_cdn_link =
  let cdn_link = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" in
  link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
  ()

(* Login Button *)
let login = link_to ~address:"login"
                    ~content:([Raw.span ~a:[a_class ["glyphicon glyphicon-log-in"]]
                                        [pcdata " Login via Facebook"]])


(* Header Navbar html skeleton *)
let header_navbar_skeleton =
  nav ~a:[a_class ["navbar navbar-inverse navbar-fixed-top"]]
  [div ~a:[a_class ["container-fluid"]]
   [div ~a:[a_class ["navbar-header"]] [news_link];
    div
    [ul ~a:[a_class ["nav navbar-nav navbar-right"]]
     [li [login]] (* /ul *)
    ] (* /div *)
   ] (* /div *)
  ] (* /div *)

{shared{
  open Eliom_lib
  open Eliom_content
  open Html5.D
}}

module UC_app =
  Eliom_registration.App (
    struct
      let application_name = "UC"
    end)

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  UC_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"UC"
           ~css:[["css";"UC.css"]]
           Html5.F.(body [
             h2 [pcdata "Welcome from Eliom's distillery!"];
           ])))
