type cache_t = {
  cache_dir : string;
  db_path : string;
  busy_timeout : int;
  in_memory : bool;
}

val create_cache : AppDir.t -> Config.t -> cache_t

module Resource :
sig
  module State :
  sig
    type t =
        Synchronized
      | ToDownload
      | Downloading
      | ToUpload
      | Uploading
      | NotFound

    val to_string : t -> string
    val of_string : string -> t
  end

  type t = {
    id : int64;
    remote_id : string option;
    name : string option;
    mime_type : string option;
    created_time : float option;
    modified_time : float option;
    viewed_by_me_time : float option;
    file_extension : string option;
    full_file_extension : string option;
    md5_checksum : string option;
    size : int64 option;
    can_edit : bool option;
    trashed : bool option;
    web_view_link : string option;
    version : int64 option;
    file_mode_bits : int64 option;
    uid : int64 option;
    gid : int64 option;
    link_target : string option;
    xattrs : string;
    parent_path : string;
    path : string;
    state : State.t;
    last_update : float;
  }

  val id : (t, int64) GapiLens.t
  val remote_id : (t, string option) GapiLens.t
  val name : (t, string option) GapiLens.t
  val mime_type : (t, string option) GapiLens.t
  val created_time : (t, float option) GapiLens.t
  val modified_time : (t, float option) GapiLens.t
  val viewed_by_me_time : (t, float option) GapiLens.t
  val file_extension : (t, string option) GapiLens.t
  val full_file_extension : (t, string option) GapiLens.t
  val md5_checksum : (t, string option) GapiLens.t
  val size : (t, int64 option) GapiLens.t
  val can_edit : (t, bool option) GapiLens.t
  val trashed : (t, bool option) GapiLens.t
  val web_view_link : (t, string option) GapiLens.t
  val version : (t, int64 option) GapiLens.t
  val file_mode_bits : (t, int64 option) GapiLens.t
  val uid : (t, int64 option) GapiLens.t
  val gid : (t, int64 option) GapiLens.t
  val link_target : (t, string option) GapiLens.t
  val xattrs : (t, string) GapiLens.t
  val parent_path : (t, string) GapiLens.t
  val path : (t, string) GapiLens.t
  val state : (t, State.t) GapiLens.t
  val last_update : (t, float) GapiLens.t

  val file_mode_bits_to_kind : int64 -> Unix.file_kind
  val file_mode_bits_to_perm : int64 -> int
  val render_xattrs : (string * string) list -> string
  val parse_xattrs : string -> (string * string) list
  val find_app_property : 'a -> ('a * 'b) list -> 'b option
  val app_property_to_int64 : string option -> int64 option
  val get_file_mode_bits : (string * string) list -> int64 option
  val file_mode_bits_to_app_property : int64 option -> string * string
  val mode_to_app_property : int -> string * string
  val get_uid : (string * string) list -> int64 option
  val uid_to_app_property : 'a -> string * 'a
  val get_gid : (string * string) list -> int64 option
  val gid_to_app_property : 'a -> string * 'a
  val get_link_target : (string * 'a) list -> 'a option
  val link_target_to_app_property : 'a -> string * 'a
  val get_xattrs : (string * string) list -> string
  val xattr_to_app_property : string -> 'a -> string * 'a
  val xattr_no_value_to_app_property : string -> string * string

  val insert_resource : cache_t -> t -> t
  val update_resource : cache_t -> t -> unit
  val update_resource_state : cache_t -> State.t -> int64 -> unit
  val update_resource_state_and_size :
    cache_t -> State.t -> int64 -> int64 -> unit
  val delete_resource : cache_t -> t -> unit
  val delete_not_found_resource_with_path : cache_t -> string -> unit
  val delete_resources : cache_t -> t list -> unit
  val insert_resources : cache_t -> t list -> string -> bool -> t list
  val invalidate_resources : cache_t -> int64 list -> unit
  val invalidate_path : cache_t -> string -> unit
  val invalidate_all : cache_t -> unit
  val invalidate_trash_bin : cache_t -> unit
  val trash_resources : cache_t -> t list -> unit
  val delete_all_with_parent_path : cache_t -> string -> bool -> unit
  val trash_all_with_parent_path : cache_t -> string -> unit
  val update_all_timestamps : cache_t -> float -> unit
  val select_resource_with_path : cache_t -> string -> bool -> t option
  val select_resource_with_remote_id : cache_t -> string -> t option
  val select_resources_with_parent_path : cache_t -> string -> bool -> t list
  val select_resources_order_by_last_update : cache_t -> t list

  val is_folder : t -> bool
  val is_document_mime_type : string -> bool
  val is_document : t -> bool
  val is_symlink : t -> bool
  val is_valid : t -> float -> bool
  val is_large_file : Config.t -> t -> bool
  val to_stream : Config.t -> t -> bool * bool

  val get_format_from_mime_type : string -> Config.t -> string
  val get_format : t -> Config.t -> string
  val get_icon_from_mime_type : string -> Config.t -> string
  val get_icon : t -> Config.t -> string
  val mime_type_of_format : string -> string

end

module Metadata :
sig
  type t = {
    display_name : string;
    storage_quota_limit : int64;
    storage_quota_usage : int64;
    start_page_token : string;
    cache_size : int64;
    last_update : float;
  }

  val display_name : (t, string) GapiLens.t
  val storage_quota_limit : (t, int64) GapiLens.t
  val storage_quota_usage : (t, int64) GapiLens.t
  val start_page_token : (t, string) GapiLens.t
  val cache_size : (t, int64) GapiLens.t
  val last_update : (t, float) GapiLens.t

  val insert_metadata : cache_t -> t -> unit
  val select_metadata : cache_t -> t option
  val update_cache_size : cache_t -> int64 -> unit
  val is_valid : int -> t -> bool
end

val get_content_path : cache_t -> Resource.t -> string
val delete_files_from_cache : cache_t -> Resource.t list -> int64
val setup_db : cache_t -> unit
val clean_up_cache : cache_t -> unit
val compute_cache_size : cache_t -> int64

