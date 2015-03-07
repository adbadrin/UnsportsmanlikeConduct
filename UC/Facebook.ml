(* Facebook API functions *)
(* by Thomas Brittain *)

(* To Compile: ocamlfind ocamlc -thread *)
(*                              -package core,netclient,equeue-ssl,lwt *)
(*                              -linkpkg Facebook.ml *)

(*
#require "netclient";;
#require "equeue-ssl";;
#require "uri";;
#require "lwt";;
#require "lwt.syntax";;

#require "uri";;
#require "cohttp.lwt";;
*)

let facebook_app_id = "1432703690354746"
let app_secret = "01a6334b2c71020d23b16a022d1c316b"

(* WTF OCaml?! Why do you do this to me? *)
let (>>=) = Lwt.bind

(* User type *)
type user = {first_name : string; last_name : string; uc_username : string;
             email_address : string; access_token : string; expires : int}

(* Facebook user verification type *)
(* Success of (access_token, seconds to timeout) *)
type verification_result = Success of user | Failure of user

let dummy_verify () = 
    Success {first_name = "Jimmy"; last_name = "Dean"; uc_username = "JimmyDeanSausage";
             email_address = "jimmydea@jimmydeansausage.com"; access_token = "69";
             expires = 69}


(* Cohttp version *)
let verify_user_2 code_parameter =
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
  >>= fun s -> Core.Core_string.split_on_chars s ~on:['='; '&'] |> Lwt.return
  >>= fun l ->
    match (l, List.mem "access_token" l) with
    | (l, true) -> Success {first_name = ""; last_name = ""; uc_username = "";
                            email_address = ""; access_token = List.nth l 1;
                            expires = List.nth l 3 |> int_of_string}
                   |> Lwt.return
    | (_, false) -> Failure {first_name = ""; last_name = ""; uc_username = "";
                             email_address = ""; access_token = ""; expires = 0}
                    |> Lwt.return


(* Check if the user is logged into facebook *)
(* let is_logged_in user = *)

