class FCM {
  static String saveToken(String token, String group){
    String query = "SELECT public.tbl_savetokenfcm ('$token','$group')";
    return query;
  }
  static String notUseToken(String token){
    String query = "SELECT public.tbl_notusetokenfcm ('$token')";
    return query;
  }
}