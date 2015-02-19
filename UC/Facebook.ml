(* Facebook API functions *)
(* by Thomas Brittain *)

#require "netclient";;
#require "equeue-ssl";;
#require "lwt";;

let facebook_app_id = "1432703690354746"
let app_secret = "01a6334b2c71020d23b16a022d1c316b"

(* WTF OCaml?! Why do you do this to me? *)
let (>>=) = Lwt.bind

(* User type *)
type user = {first_name : string; last_name : string; uc_username : string; email_address : string}

(* after you get the code parameter from the facebook redirect: *)
(* (1) verify the user by exchaniging the code for an access token using an endpoint *)

(* Verify the user *)
(* exchange the code parameter from the facebook redirect for an access token using an endpoint *)
let verify_user code_parameter =
  let redirect_uri = "http://localhost:8080/gameplay" in
  let o_auth_endpoint = ("https://graph.facebook.com/oauth/access_token?" ^
                         "client_id=" ^ facebook_app_id ^
                         "&redirect_uri=" ^ redirect_uri ^
                         "&client_secret=" ^ app_secret ^
                         "&code=" ^ code_parameter)
  in
  (* make HTTP GET request to the OAuth endpoint *)

  (* successful response: access_token={access-token}&expires={seconds-til-expiration} *)
  (* TODO: fix this seciton to be lwt friendly, it is currently all fucked up *)
  Ssl.init ();
  let ctx = Ssl.create_context Ssl.TLSv1 Ssl.Client_context in
  let tct = Https_client.https_transport_channel_type ctx in
  let pipe_ssl = new Http_client.pipeline in
    pipe_ssl#configure_transport Http_client.https_cb_id tct;
  let request = new Http_client.get o_auth_endpoint in
    pipe_ssl#add request;
    pipe_ssl#run ();
    request
    
(* "{\"error\":{\"message\":\"This authorization code has been used.\",\"type\":\"OAuthException\",\"code\":100}}" *)

(* Check if the user is logged into facebook *)
(* let is_logged_in user = *)

