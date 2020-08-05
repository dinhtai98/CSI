class Request{
  static String query_GetAllRequestsOfHatchery(String idHatchery, int responded){
    String check = '';
    if(responded == 2)
      check = 'IS NULL';
    else
      check = 'IS NOT NULL';
    String query = "4" + "^" + "SELECT \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" as \"att1\", \n" +
        "\"Tbl_BroodstockPrecontract\".\"IDRequestContract\" as \"att2\", \"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att3\",\n" +
        "\"RequestContractDate\" as \"att4\"\n" +
        "FROM \"Tbl_BroodstockTrader\", (\"Tbl_BroodstockRequestContract\" LEFT JOIN \"Tbl_BroodstockPrecontract\" \n" +
        "ON \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" = \"Tbl_BroodstockPrecontract\".\"IDRequestContract\") \n" +
        "WHERE \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" = \"Tbl_BroodstockRequestContract\".\"IDTrader\" AND \n" +
        "\"Tbl_BroodstockRequestContract\".\"IDHatchery\" = '$idHatchery' AND \"Tbl_BroodstockPrecontract\".\"IDRequestContract\" $check \n" +
        "ORDER BY \"Tbl_BroodstockRequestContract\".\"RequestContractDate\" DESC";
    return query;
  }
  static String queryGetAllRequestsOfHatcheryFilterDate(String idHatchery, String date){
    String query = "4" + "^" + "SELECT \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" as \"att1\", \n" +
        "\"Tbl_BroodstockPrecontract\".\"IDRequestContract\" as \"att2\", \"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att3\",\n" +
        "\"RequestContractDate\" as \"att4\"\n" +
        "FROM \"Tbl_BroodstockTrader\", (\"Tbl_BroodstockRequestContract\" LEFT JOIN \"Tbl_BroodstockPrecontract\" \n" +
        "ON \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" = \"Tbl_BroodstockPrecontract\".\"IDRequestContract\") \n" +
        "WHERE \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" = \"Tbl_BroodstockRequestContract\".\"IDTrader\" AND \n" +
        "\"Tbl_BroodstockRequestContract\".\"IDHatchery\" = '$idHatchery' AND \n" +
        "CAST(\"Tbl_BroodstockRequestContract\".\"RequestContractDate\" AS DATE) = '$date'\n" +
        "ORDER BY \"Tbl_BroodstockRequestContract\".\"RequestContractDate\" DESC";
    return query;
  }
  static String queryGetAllRequestsOfTrader(String idTrader, int responded){
    String check = '';
    if(responded == 1)
      check = 'IS NOT NULL';
    else
      check = 'IS NULL';
    String query = "4" + "^" + "SELECT \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" as \"att1\", \n" +
        "\"Tbl_BroodstockPrecontract\".\"IDRequestContract\" as \"att2\", \"Tbl_Hatchery\".\"HatcheryName\" as \"att3\",\n" +
        "\"RequestContractDate\" as \"att4\"\n" +
        "FROM \"Tbl_Hatchery\", (\"Tbl_BroodstockRequestContract\" LEFT JOIN \"Tbl_BroodstockPrecontract\"\n" +
        "ON \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" = \"Tbl_BroodstockPrecontract\".\"IDRequestContract\") \n" +
        "WHERE \"Tbl_Hatchery\".\"IDHatchery\" = \"Tbl_BroodstockRequestContract\".\"IDHatchery\" AND \n" +
        "\"Tbl_BroodstockRequestContract\".\"IDTrader\" = '$idTrader' AND \"Tbl_BroodstockPrecontract\".\"IDRequestContract\" $check\n" +
        "ORDER BY \"Tbl_BroodstockRequestContract\".\"RequestContractDate\" DESC";
    return query;
  }
  static String queryGetAllRequestsOfTraderFilterDate(String idTrader, String date){
    String query = "4" + "^" + "SELECT \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" as \"att1\", \n" +
        "\"Tbl_BroodstockPrecontract\".\"IDRequestContract\" as \"att2\", \"Tbl_Hatchery\".\"HatcheryName\" as \"att3\",\n" +
        "\"RequestContractDate\" as \"att4\"\n" +
        "FROM \"Tbl_Hatchery\", (\"Tbl_BroodstockRequestContract\" LEFT JOIN \"Tbl_BroodstockPrecontract\"\n" +
        "ON \"Tbl_BroodstockRequestContract\".\"IDRequestContract\" = \"Tbl_BroodstockPrecontract\".\"IDRequestContract\") \n" +
        "WHERE \"Tbl_Hatchery\".\"IDHatchery\" = \"Tbl_BroodstockRequestContract\".\"IDHatchery\" AND \n" +
        "\"Tbl_BroodstockRequestContract\".\"IDTrader\" = '$idTrader' AND \n" +
        "CAST(\"Tbl_BroodstockRequestContract\".\"RequestContractDate\" AS DATE) = '$date'\n" +
        "ORDER BY \"Tbl_BroodstockRequestContract\".\"RequestContractDate\" DESC";
    return query;
  }
  static String query_findRequest(String idRequest){
    String query = "8" + "^" +"Select \"Tbl_BroodstockProducer\".\"BroodstockProducerName\" as \"att1\",\"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att2\", \n" +
        "\"BroodstockSpecies\" as \"att3\", \"BroodstockTypes\" as \"att4\", \"NumOfPair\" as \"att5\", \n" +
        "\"ExpectedTime\" as \"att6\", \"RequestContractDate\" as \"att7\", \"IDHatchery\" as \"att8\" \n" +
        "FROM \"Tbl_BroodstockRequestContract\", \"Tbl_BroodstockTrader\", \"Tbl_BroodstockProducer\" \n" +
        "WHERE \"Tbl_BroodstockRequestContract\".\"IDTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" AND \n" +
        "\"Tbl_BroodstockRequestContract\".\"IDProducer\" = \"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" AND \n" +
        "\"IDRequestContract\" = '$idRequest'";
    return query;
  }

  static String query_CheckRequest_Responsed(String idRequest){
    String query = "11" + "^" + "SELECT \"Tbl_BroodstockProducer\".\"BroodstockProducerName\" as \"att1\",\"BroodstockSpecies\" as \"att2\", \n" +
        "\"BroodstockTypes\"as \"att3\",\"UnitPrice\" as \"att4\", \"NumOfPair\" as \"att5\",\"ExpectedDeliveryDate\" as \"att6\", \n" +
        "\"ArrivalPort\" as \"att7\",\"ArrivalTimePort\" as \"att8\",\"Bonus\" as \"att9\",\"Note\" as \"att10\",\"PreContractDate\" as \"att11\" \n" +
        "FROM \"Tbl_BroodstockPrecontract\", \"Tbl_BroodstockProducer\" \n" +
        "WHERE \"Tbl_BroodstockPrecontract\".\"IDProducer\" = \"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" AND \n" +
        "\"IDRequestContract\" = '$idRequest'";
    return query;
  }
  static String query_InsertNewRequest(String IDHat, String IDTra, String species, int numberOfPair ,String expectedTime, String IDPro, String types){
    String query = "1^select procinserttbl_broodstockrequestcontract('${IDHat}','${IDTra}','${species}','${numberOfPair}','${expectedTime}','${IDPro}','${types}') as \"att1\" ";
    return query;
  }
  static String query_InsertResponse(String IDReq, String species, int numofpair, int price, String delidate, String arrivalPort, String arrivalTime,String bonus, String IDPro,String type,String note){
    String query = "select procInsertTbl_BroodstockPrecontract('$IDReq','$species','$numofpair','$price','$delidate','$arrivalPort','$arrivalTime','$bonus','$IDPro','$type','$note')";
    return query;
  }
}