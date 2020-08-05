class DAH{
  static String query_getAllStaffDAH = "13" + "^" + "Select \"IDDAHStaff\" as \"att1\", \"DAHStaffLastName\" as \"att2\", \"DAHStaffFirstName\" as \"att3\",\n"+
      "\"DAHStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"DAHStaffEmail\" as \"att6\", \"IDDAH\" as \"att7\",\n"+
      "\"Username\" as \"att8\", \"Password\" as \"att9\",\"Active\" as \"att10\",\"CreatedDate\" as \"att11\" from public.\"Tbl_DAHStaff\"";
  static String queryGetStaffDAH(String idStaff){
    String query = "11" + "^" + "Select \"IDDAHStaff\" as \"att1\", \"DAHStaffLastName\" as \"att2\", \"DAHStaffFirstName\" as \"att3\",\n" +
        "\"DAHStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"DAHStaffEmail\" as \"att6\", \"Tbl_DAH\".\"DAHName\" as \"att7\",\n" +
        "\"Username\" as \"att8\", \"Password\" as \"att9\",\"Active\" as \"att10\",\"CreatedDate\" as \"att11\" \n" +
        "from public.\"Tbl_DAHStaff\", \"Tbl_DAH\"\n" +
        "where \"Tbl_DAHStaff\".\"IDDAH\" = \"Tbl_DAH\".\"IDDAH\" AND\n" +
        "\"IDDAHStaff\" = '$idStaff'";
    return query;
  }
  static String queryDAHEventsDate(String idProvince){
    String query = "1" + "^" + "SELECT DISTINCT CAST(\"ArrivalTimePort\" AS DATE) as \"att1\"\n" +
        "FROM \"Tbl_HatcheryNew\" ,\"Tbl_BroodstockImportContract\"\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = '$idProvince'";
    return query;
  }
  static String queryGetAllImportContractDAHClearanceByDate(String idProvince, String date){
    String query = "5" + "^" + "SELECT \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\",\n" +
        "COALESCE(to_char(\"ArrivalTimePort\", 'HH24:MI:SS'), '') AS \"att3\", \"ArrivalPort\" as \"att4\" ,\"Tbl_DAHClearance\".\"ApproveStatus\" as \"att5\"\n" +
        "FROM \"Tbl_HatcheryNew\" ,\n" +
        "(\"Tbl_BroodstockImportContract\" LEFT JOIN \"Tbl_DAHClearance\" ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_DAHClearance\".\"IDBroodstockContract\")\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = '$idProvince' AND \"ArrivalTimePort\"::timestamp::DATE = '$date'\n" +
        "ORDER BY \"ArrivalTimePort\"::timestamp::time ASC";
    return query;
  }
  static String queryDAHFindDARDAndArrivalTimeHatFromContract(String idCon){
    String query = "10^SELECT \"dard\".\"IDManagementAuthority\" as \"att1\", \"Tbl_BroodstockImportContract\".\"ArrivalTimeHatchery\" as \"att2\", \n" +
        "\"Tbl_HatcheryNew\".\"HatcheryName\" as \"att3\", \"dard\".\"NameAuthority\" as \"att4\", \n" +
        "\"Tbl_DAHClearance\".\"IDBroodstockContract\" as \"att5\",\"Tbl_DAHClearance\".\"PhotoOfDAHApprove\" as \"att6\",\n" +
        "\"DAHApproveDate\" as \"att7\", \"ApproveStatus\" as \"att8\", \"Tbl_User\".\"FullName\" as \"att9\"\n" +
        "FROM \"Tbl_HatcheryNew\", \"Tbl_ManagementAuthority\" as \"dard\",\n" +
        "(\"Tbl_BroodstockImportContract\" LEFT JOIN \"Tbl_DAHClearance\"  ON \n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" =\n" +
        "\"Tbl_DAHClearance\".\"IDBroodstockContract\" LEFT JOIN \"Tbl_User\" ON\n" +
        " \"Tbl_User\".\"IDUser\" = \"Tbl_DAHClearance\".\"IDDAHStaff\")\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = \"dard\".\"Province\" AND \"dard\".\"Type\" = 4 AND \n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryDAHClearanceInfoToDARD(String idCon, String idDAHStaff, String photoApprove, String idSender,
      String idReceiver, String senderName, String receiverName, String content){
    String query = "select procInsertTbl_DAHClearance_Tbl_Inform ('$idCon','$idDAHStaff','$photoApprove','$idSender',"
        "'$idReceiver','$senderName','$receiverName','$content')";
    return query;

  }
}