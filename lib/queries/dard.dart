class DARD{
  static String query_getAllStaffDARD = "13" + "^" + "Select \"IDDARDStaff\" as \"att1\", \"DARDStaffLastName\" as \"att2\", \"DARDStaffFirstName\" as \"att3\", \n" +
      "\"DARDStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"DARDStaffEmail\" as \"att6\",\"IDDARD\" as \"att7\",\n" +
      "\"Username\" as \"att8\", \"Password\" as \"att9\",\"Active\" as \"att10\",\"CreatedDate\" as \"att11\" from public.\"Tbl_DARDStaff\" ";
  static String queryGetStaffDARD(String idStaff){
    String query = "11" + "^" + "Select \"IDDARDStaff\" as \"att1\", \"DARDStaffLastName\" as \"att2\", \"DARDStaffFirstName\" as \"att3\", \n" +
        "\"DARDStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"DARDStaffEmail\" as \"att6\",\"Tbl_DARD\".\"DARDName\" as \"att7\",\n" +
        "\"Username\" as \"att8\", \"Password\" as \"att9\",\"Active\" as \"att10\",\"CreatedDate\" as \"att11\"\n" +
        "from public.\"Tbl_DARDStaff\", \"Tbl_DARD\"\n" +
        "WHERE \"Tbl_DARDStaff\".\"IDDARD\" = \"Tbl_DARD\".\"IDDARD\" AND\n" +
        "\"IDDARDStaff\" = '$idStaff' ";
    return query;
  }
  static String queryAllEventsDARD(String idProvince){
    String query = "2"+"^"+"SELECT CAST(\"ArrivalTimeHatchery\" AS DATE) as \"att1\", CAST(\"StartingQuarantineTime\" AS DATE) as \"att2\"\n" +
        "FROM \"Tbl_HatcheryNew\", \"Tbl_BroodstockImportContract\" LEFT JOIN \"Tbl_QuarantineClearance\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_QuarantineClearance\".\"IDBroodstockContract\"\n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"Tbl_BroodstockImportContract\".\"IDHatchery\" AND\n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = '$idProvince'\n" +
        "ORDER BY CAST(\"ArrivalTimeHatchery\" as Time) ASC";
    return query;
  }
  static String queryEventsDARDByDate(String idProvince, String date){
    String query = "6^SELECT 1 as \"att6\",\"Tbl_HatcheryNew\".\"IDHatchery\" as \"att1\",\"HatcheryName\" as \"att2\",\n" +
        "COALESCE(to_char(\"ArrivalTimeHatchery\", 'HH24:MI:SS'), '') as \"att3\",\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att4\", \"QuarantineStatus\" as \"att5\"\n" +
        "FROM \"Tbl_HatcheryNew\", \"Tbl_BroodstockImportContract\" LEFT JOIN \"Tbl_QuarantineClearance\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_QuarantineClearance\".\"IDBroodstockContract\"\n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"Tbl_BroodstockImportContract\".\"IDHatchery\" AND \n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = '$idProvince' AND CAST(\"ArrivalTimeHatchery\" AS DATE) = '$date' \n" +
        "UNION \n" +
        "SELECT 2 as \"att6\",\"Tbl_HatcheryNew\".\"IDHatchery\" as \"att1\",\"HatcheryName\" as \"att2\",\n" +
        "COALESCE(to_char(\"StartingQuarantineTime\", 'HH24:MI:SS'), '') as \"att3\",\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att4\" , \"QuarantineStatus\" as \"att5\" \n" +
        "FROM \"Tbl_HatcheryNew\", \"Tbl_BroodstockImportContract\", \"Tbl_QuarantineClearance\"\n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"Tbl_BroodstockImportContract\".\"IDHatchery\" AND\n" +
        "\"Tbl_QuarantineClearance\".\"IDBroodstockContract\" = \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" AND\n" +
        "\"Tbl_HatcheryNew\".\"IDProvince\" = '$idProvince' AND \n" +
        "CAST(\"StartingQuarantineTime\" AS DATE) + interval '10' day = '$date'\n" +
        "ORDER BY 1";
    return query;
  }
  static String queryGetInFoImportContractQuarantine(String idCon){
    String query = "13" + "^" + "SELECT \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\",\n" +
        "\"Tbl_BroodstockProducer\".\"BroodstockProducerName\" as \"att3\", \"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att4\", \n" +
        "\"BroodstockSpecies\" as \"att5\", \"BroodstockTypes\" as \"att6\", \"UnitPrice\" as \"att7\", \"NumberOfPair\" as \"att8\", \n" +
        "\"Bonus\" as \"att9\", \"Tbl_QuarantineClearance\".\"QuarantineStatus\" as \"att10\", \"Tbl_HatcheryNew\".\"IDHatchery\" as \"att11\",\n" +
        "\"StartingQuarantineTime\" as \"att12\", \"ClearanceTime\" as \"att13\"\n" +
        "FROM \"Tbl_BroodstockBatch\", \"Tbl_HatcheryNew\", \"Tbl_BroodstockProducer\", \"Tbl_BroodstockTrader\",\n" +
        "(\"Tbl_BroodstockImportContract\" LEFT JOIN  \"Tbl_QuarantineClearance\"\n" +
        "ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_QuarantineClearance\".\"IDBroodstockContract\")\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_BroodstockBatch\".\"IDBroodstockContract\" AND \n" +
        "\"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockProducer\" = \"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryDARDQuarantine(String idCon, String staff, String company, String content){
    String query = "select procInsertTbl_DARDQuarantine_Tbl_Inform ('$idCon','$staff','$company','$content')";
    return query;
  }
  static String queryDARDQuarantineClearance(String idCon, String staff){
    String query = "select procinserttbl_dard_clearance_quarantine_tbl_inform ('$idCon','$staff')";
    return query;
  }
}