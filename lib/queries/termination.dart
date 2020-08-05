class Termination{
  static String queryGetTerminationOfBroodStockSub(String idSub){
    String query = "6"+"^"+"SELECT \"IDBroodstockTermination\" as \"att1\", \"IDBroodstockSubBatch\" as \"att2\",\n" +
        "\"CullPlanDate\" as \"att3\", \"CullReasonPlan\" as \"att4\", \"NumOfMalePlan\" as \"att5\",\n" +
        "\"NumOfFemalePlan\" as \"att6\"\n" +
        "FROM \"Tbl_BroodstockTermination\"\n" +
        "WHERE \"IDBroodstockSubBatch\" = '$idSub'";
    return query;
  }
  static String queryGetAllDARDStaffOfHatchery(String idHatchery){
    String query = "2"+"^"+"SELECT \"Tbl_DARDStaff\".\"IDDARDStaff\" as \"att1\",\n" +
        "\"Tbl_DARDStaff\".\"DARDStaffFirstName\" || ' ' || \"Tbl_DARDStaff\".\"DARDStaffLastName\" as \"att2\"\n" +
        "FROM \"Tbl_DARDStaff\", \"Tbl_Hatchery\"\n" +
        "WHERE \"Tbl_DARDStaff\".\"IDDARD\" = \"Tbl_Hatchery\".\"IDDARD\" AND\n" +
        "\"Tbl_Hatchery\".\"IDHatchery\" = '$idHatchery'";
    return query;
  }

  static String executeTerminationBroodstockSubBatch(String idTer, String idSub, String idStaffHatchery, String idDARDStaff, String reason, String datetime){
    String query = "SELECT procterminationbroodstocksubbatch ('$idTer','$idSub','$idStaffHatchery','$idDARDStaff','$reason','$datetime')";
    return query;
  }
}