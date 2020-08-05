class CoQuanQuanLy {

  static String queryGetCQQL = "25^SELECT \"NameAuthority\" as \"att1\", \"Website\" as \"att2\", \"Avatar\" as \"att3\",\n" +
      "\"Tbl_ManagementAuthority\".\"Address\" as \"att4\", \"ImmediateSupervisingAuthority\" as \"att5\", \n" +
      "\"Tbl_ManagementAuthority\".\"Phone\" as \"att6\",\"NumberOfStaff\" as \"att7\", \n" +
      "\"ManagementLevel\" as \"att8\", \"Type\" as \"att9\",\n" +
      "\"Username\" as \"att18\", \"Password\" as \"att19\",\n" +
      "\"IDNumber\" as \"att20\", \"TypeAuthority\" as \"att21\"\n" +
      "FROM \"Tbl_User\", \"Tbl_ManagementAuthority\"\n" +
      "WHERE \"Tbl_User\".\"WorkPlace\" = \"Tbl_ManagementAuthority\".\"IDManagementAuthority\"";

  static String queryGetCoQuanQuanLyTheoLoai(int type){
    String query = "2 ^ SELECT \"IDManagementAuthority\" as \"att1\", \"NameAuthority\" as \"att2\"\n" +
        "FROM \"Tbl_ManagementAuthority\"\n" +
        "WHERE \"Type\" = $type";
    return query;
  }
  static String queryDangKyCoQuanQuanLy(String name, String provinces, int type, int managementLevel){
    String query = "1^SELECT public.procinserttbl_managementauthority('$name', '$managementLevel', '$provinces', '$type') as \"att1\" ";
    return query;
  }

  static String queryGetProvinceCoQuanQuanLy(String idAuthor){
    String query = "1 ^ SELECT \"Province\" as \"att1\"\n " +
        " FROM \"Tbl_ManagementAuthority\" \n" +
        " WHERE \"IDManagementAuthority\" = '$idAuthor' ";

    return query;
  }

  static String queryGetCoQuanQuanLy(String idAuthor){
    String query = "11 ^ SELECT \"NameAuthority\" as \"att1\", \"ManagementLevel\" as \"att2\" , \"Province\" as \"att3\",\n" +
        "\"Website\" as \"att4\", \"Photo\" as \"att5\", \"Tbl_ManagementAuthority\".\"Address\" as \"att6\",\n" +
        "\"Tbl_ManagementAuthority\".\"Phone\" as \"att7\",\n" +
        "\"ImmediateSupervisingAuthority\" as \"att8\", \"IDLeader\" as \"att9\", \"NumberOfStaff\" as \"att10\",\n" +
        "\"Username\" as \"att11\"\n" +
        "FROM \"Tbl_ManagementAuthority\", \"Tbl_User\"\n" +
        "WHERE \"Tbl_ManagementAuthority\".\"IDManagementAuthority\" = \"Tbl_User\".\"WorkPlace\" AND\n" +
        "\"IDManagementAuthority\" = '$idAuthor'";
    return query;
  }

  static String queryGetProvinceName(String idProvince){
    String query = "1 ^ SELECT \"ProvinceName\" as \"att1\" \n" +
        "FROM \"Tbl_Province\"\n" +
        "WHERE \"IDProvince\" = '$idProvince'";
    return query;
  }
}