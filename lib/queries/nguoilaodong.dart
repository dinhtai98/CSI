class NguoiLaoDong {

  static String queryDangKyNguoiLaoDong(String name, String idNumber, String phone, String email, String address, String startYear, int expertise, int curStatus) {
    String query = "1^select * from proc_dangkynguoilaodong ('$name', '$idNumber', '$phone', '$email','$address', '$startYear', '$expertise','$curStatus')";
    return query;
  }
  static String queryGetAllUser = "25^SELECT \"IDUser\" as \"att1\", \"FullName\" as \"att2\", \"Email\" as \"att3\",\n" +
      "\"Address\" as \"att4\", \"Expertise\" as \"att5\", \"YearStartWorking\" as \"att6\",\n" +
      "\"CurrentStatus\" as \"att7\", \"TypeOfAccount\" as \"att8\", \"ManagementRight\" as \"att9\",\n" +
      "\"ManagementRightList\" as \"att10\", \"ManagementUnitsResponseFor\" as \"att11\",\n" +
      "\"ManagementSpecificUnits\" as \"att12\", \"LineManager\" as \"att13\",\n" +
      "\"ProductionUnitsResponseFor\" as \"att14\", \"ProductionClustersResponseFor\" as \"att15\",\n" +
      "\"WorkPlace\" as \"att16\", \"AgencyNotes\" as \"att17\", \"Username\" as \"att18\", \"Password\" as \"att19\",\n" +
      "\"IDNumber\" as \"att20\", \"TypeAuthority\" as \"att21\"\n" +
      "FROM \"Tbl_User\"";
  static String queryGetThongTinCaNhanNguoiLaoDong(String idUser){
    String query = "10 ^ SELECT \"WorkPlace\" as \"att1\", \"IDUser\" as \"att2\",\n" +
        "\"FullName\" as \"att3\", \"IDNumber\" as \"att4\",\n" +
        "\"Phone\" as \"att5\", \"Email\" as \"att6\", \"Address\" as \"att7\",\n" +
        "\"Expertise\" as \"att8\", \"YearStartWorking\" as \"att9\", \"CurrentStatus\" as \"att10\"\n" +
        "FROM \"Tbl_User\"\n" +
        "WHERE \"Tbl_User\".\"TypeAuthority\" = 4 AND\n" +
        "\"IDUser\" = '$idUser'";
    return query;
  }
}