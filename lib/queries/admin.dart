class Admin{
  static String queryChangePassword(String idUser, String oldPass, String newPass){
    String query = "SELECT public.procchangeadminpassword('$idUser','$oldPass','$newPass')";
    return query;

  }
}