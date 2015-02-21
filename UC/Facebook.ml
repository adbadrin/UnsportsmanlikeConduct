(* Facebook API functions *)
(* by Thomas Brittain *)

#require "netclient";;
#require "equeue-ssl";;
#require "lwt";;
#require "lwt.syntax";;

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

(* after you get the code parameter from the facebook redirect: *)
(* (1) verify the user by exchaniging the code for an access token using an endpoint *)

(* Verify the user - Returns Success of access_token or Failure of msg *)
(* exchange the code parameter from the facebook redirect for an access token using an endpoint *)
(* Error message example: *)
(* "{\"error\":{\"message\":\"This authorization code has been used.\", *)
(*   \"type\":\"OAuthException\",\"code\":100}}" *)
(* Success message example: *)
(* "access_token=CAAUXCVKIMDoBAONos6kV00a8Pz8XWRjojmGIGYIgg5jXLmpySCQC9QGvJslHlxUUCu5xTuwZCMyXUm3GYQmliyAGZAjw2iiOW38tzSRcNoOYZCz2s78cZBfohOxnMDxrIZBCZBoeh5ulQnURaMkPIikIKEvQnF7LLfVqYZBgVcgZCnFGWAnP5exWP4M5kaMIDZAE662YDWpmX9m9DvJt3spKr&expires=5180876" *)
let verify_user code_parameter =
  let redirect_uri = "http://localhost:8080/gameplay" in
  let o_auth_endpoint = 
    (
      "https://graph.facebook.com/oauth/access_token?" ^ "client_id=" ^ facebook_app_id ^
      "&redirect_uri=" ^ redirect_uri ^ "&client_secret=" ^ app_secret ^ "&code=" ^ code_parameter
    )
  in
  (* make HTTP GET request to the OAuth endpoint *)
  (* successful response: access_token={access-token}&expires={seconds-til-expiration} *)
  Ssl.init ()
  |> fun () ->
    (
      let ctx = Ssl.create_context Ssl.TLSv1 Ssl.Client_context in
      let tct = Https_client.https_transport_channel_type ctx in
      let pipe_ssl = new Http_client.pipeline in
      pipe_ssl#configure_transport Http_client.https_cb_id tct
      |> fun () -> 
          (
            let request = new Http_client.get o_auth_endpoint in
            pipe_ssl#add request
            |> pipe_ssl#run
            |> fun () -> request#response_body#value
          )
    )
  |> fun s -> Core.Core_string.split_on_chars s ~on:['='; '&']
               (* access token if it exists, bool *)
  |> fun l -> (l, List.mem "access_token" l)
  |> fun (l, b) ->
      match (l, b) with
      | (l, true) -> Success {first_name = ""; last_name = ""; uc_username = "";
                              email_address = ""; access_token = List.nth l 1;
                              expires = List.nth l 3 |> int_of_string}
      | (_, false) -> Failure {first_name = ""; last_name = ""; uc_username = "";
                               email_address = ""; access_token = ""; expires = 0}


(* Check if the user is logged into facebook *)
(* let is_logged_in user = *)

