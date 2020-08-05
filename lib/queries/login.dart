class QueryLogin {

  static String queryLoginAdmin(String Username, String Password){
    return "11^SELECT 0 as \"att2\" ,\"IDAdmin\" as \"att10\", \"Username\" as \"att6\", \"Password\" as \"att7\"\n" +
        "FROM \"Tbl_SystemAdmin\"\n" +
        "WHERE \"Active\" = 1 AND \"Username\" = '$Username' AND \"Password\" = '$Password'";
  }
  static String queryLoginCQQL(String Username, String Password){
    return "11^SELECT \"Tbl_ManagementAuthority\".\"IDManagementAuthority\" as \"att1\", \n" +
        "\"TypeAuthority\" as \"att2\", \"TypeOfAccount\" as \"att3\",\n" +
        "\"NameAuthority\" as \"att4\", \"Avatar\" as \"att5\",\n" +
        "\"Username\" as \"att6\", \"Password\" as \"att7\", \"Type\" as \"att8\",\"IDUser\" as \"att10\", \"Province\" as \"att11\"\n" +
        "FROM \"Tbl_User\", \"Tbl_ManagementAuthority\" \n" +
        "WHERE \"Tbl_User\".\"WorkPlace\" = \"Tbl_ManagementAuthority\".\"IDManagementAuthority\" AND\n" +
        "(\"Tbl_User\".\"TypeAuthority\" = 1 OR \"Tbl_User\".\"TypeAuthority\" = 4) AND \"IDUser\" = '$Username' AND \"Password\" = '$Password'";
  }
  static String queryLoginCSSX(String Username, String Password){
    return "10^SELECT \"Tbl_HatcheryNew\".\"IDHatchery\" as \"att1\",\n" +
        "\"TypeAuthority\" as \"att2\", \"TypeOfAccount\" as \"att3\",\n" +
        "\"HatcheryName\" as \"att4\", \"Tbl_HatcheryNew\".\"Photo\" as \"att5\",\n" +
        "\"Username\" as \"att6\", \"Password\" as \"att7\", \n" +
        "\"TypeOfBusiness\" as \"att8\", \"TypeOfHatchery\" as \"att9\", \"IDUser\" as \"att10\"\n" +
        "FROM \"Tbl_User\", \"Tbl_HatcheryNew\"\n" +
        "WHERE \"Tbl_User\".\"WorkPlace\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "(\"Tbl_User\".\"TypeAuthority\" = 2 OR \"Tbl_User\".\"TypeAuthority\" = 4) AND \"IDUser\" = '$Username' AND \"Password\" = '$Password'";
  }
  static String queryGetDVKB(String Username, String Password){
    return "10^SELECT \"Tbl_Agency\".\"IDAgency\" as \"att1\",\n" +
        "\"TypeAuthority\" as \"att2\", \"TypeOfAccount\" as \"att3\",\n" +
        "\"AgencyName\" as \"att4\", \"Avatar\" as \"att5\",\n" +
        "\"Username\" as \"att6\", \"Password\" as \"att7\"\n" +
        "FROM \"Tbl_User\", \"Tbl_Agency\"\n" +
        "WHERE \"Tbl_User\".\"WorkPlace\" = \"Tbl_Agency\".\"IDAgency\" AND\n" +
        "(\"Tbl_User\".\"TypeAuthority\" = 3 OR \"Tbl_User\".\"TypeAuthority\" = 4) AND \"IDUser\" = '$Username' AND \"Password\" = '$Password'";
  }
  static String queryGetDNLD(String Username, String Password) {
    return "10^SELECT \"WorkPlace\" as \"att1\",\n" +
        "\"TypeAuthority\" as \"att2\", \"TypeOfAccount\" as \"att3\",\n" +
        "\"FullName\" as \"att4\", \n" +
        "\"Username\" as \"att6\", \"Password\" as \"att7\", \n" +
        "\"IDUser\" as \"att10\"\n" +
        "FROM \"Tbl_User\"\n" +
        "WHERE \"Tbl_User\".\"TypeAuthority\" = 4 AND \"IDUser\" = '$Username' AND \"Password\" = '$Password' AND \"Active\" = 1 ";
  }
  static String queryGetBuyer(String Username, String Password){
    return "11^SELECT 5 as \"att2\" ,\"IDBuyer\" as \"att10\", \"FullName\" as \"att6\", \"Password\" as \"att7\"\n" +
        "FROM \"Tbl_PostlarveaBuyer\"\n" +
        "WHERE \"IDBuyer\" = '$Username' AND \"Password\" = '$Password'";
  }
  static String queryChangePassword(String idUser, String oldPass, String newPass){
    String query = "SELECT public.procchangeuserpassword('$idUser','$oldPass','$newPass')";
    return query;

  }
}