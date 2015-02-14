(* test by running "make test.byte" in the directory containing this file*)

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
