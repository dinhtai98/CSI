class TimViec {

  static String querySearchJob(int type){
    String query = "";
    switch(type){
      case 0:
        query = "3^SELECT \"IDManagementAuthority\" as \"att1\", \"NameAuthority\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_ManagementAuthority\"";
        break;
      case 1:
        query = "3^SELECT \"IDManagementAuthority\" as \"att1\", \"NameAuthority\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_ManagementAuthority\"";
        break;
      case 2:
        query = "3^SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_HatcheryNew\"\n" +
            "WHERE \"TypeOfHatchery\" = 1";
        break;
      case 3:
        query = "3^SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_HatcheryNew\"\n" +
            "WHERE \"TypeOfHatchery\" = 2";
        break;
      case 4:
        query = "3^SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_HatcheryNew\"\n" +
            "WHERE \"TypeOfHatchery\" = 3";
        break;
      case 5:
        query = "3^SELECT \"IDAgency\" as \"att1\", \"AgencyName\" as \"att2\",\n" +
            "\"Address\" as \"att3\"\n" +
            "FROM \"Tbl_Agency\"";
        break;
    }
    return query;
  }
  static String queryApplyCompany(String idHatchery, String idCompany){
    // proc_nguoilaodongxinvocongty
    String query = "select * from proc_nguoilaodongxinvocongty ('$idHatchery', '$idCompany')";
    return query;
  }
}