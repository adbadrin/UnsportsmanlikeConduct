(* MySQL reader and writer functions *)
(* TODO: Use the Mysql error_code type where necessary *)
(* case sensitive : password *)
(* not case sensitive : username, email_address *)

(* to launch the MySQL monitor: mysql -u root -p *)

open Mysql


(* user_info type *)
type user_info = {user_id : int; username : string; password : string; email_address : string;
                  ip : string; verified : bool}


(* Define if a user was successfully written to a the database *)
type user_write_result = Success of user_info | Failure of user_info


(* Database *)
let user_db = {dbhost = None; dbname = Some "UC_DB"; dbport = Some 3306;
               dbpwd = None; dbuser = Some "root"; dbsocket = None}


(* Check if username, or e-mail address already exist in database *)
let user_exists (conn : dbd) (u : user_info) =
  let query =
    "select user_id from News_db.users where username = '" ^ u.username ^
    "' or email_address = '" ^ u.email_address ^ "'"
  in
  let query_result = exec conn query in
  if (size query_result) = Int64.zero then false else true


(* Connect, write a new user to the a database and disconnect *)
let write_user_to_db (u : user_info) =
  let conn = connect user_db in
  if (user_exists conn u) then
    disconnect conn |> fun _ -> Failure u
  else
    let sql_stmt =
      "insert into News_db.users (username, password, email_address, ip, verified)" ^
      "values('" ^ u.username ^ "', '" ^ u.password ^ "', '" ^ u.email_address ^ "', '" ^
      u.ip ^ "', '" ^ (string_of_bool u.verified) ^ "')"
    in
    exec conn sql_stmt
    |> fun _ ->
        match (user_exists conn u) with
        | true -> disconnect conn |> fun () -> Success u
        | false -> disconnect conn |> fun () -> Failure u


(* Add hashtags for user
let add_hashtags (u : user_info) hashtags_to_add =
  let conn = connect user_db in
  (* get existing hashtags *)
  let old_hashtags_query =
    "select hashtags from News_db.users where username = '" ^ u.username ^ "'"
  in
  let old_hashtags =
    exec conn old_hashtags_query
    |> fetch
    |> (fun x -> match x with Some y -> y | None -> [||])
    |> (fun a -> if Array.length a = 0 then (Some "") else Array.get a 0)
    |> (fun x -> match x with Some y -> y | None -> "")
    |> fun x -> Core.Std.String.split_on_chars x ~on:['#']
    |> List.filter (fun x -> not (x = ""))
  in
  (* filter hashtags_to_add so that you don't write a hashtag twice *)
  let new_hashtags =
    List.map (fun x -> if List.mem x old_hashtags then "" else x) hashtags_to_add
    |> List.filter (fun x -> not(x = ""))
  in
  (* write new hashtags *)
  let hashtags_string = old_hashtags @ new_hashtags |> List.fold_left (fun x y -> x ^ "#" ^ y) "" in
  let sql_stmt =
    "update News_db.users set hashtags = '" ^ hashtags_string ^
    "' where username = '" ^ u.username ^ "'"
  in
  exec conn sql_stmt*)
