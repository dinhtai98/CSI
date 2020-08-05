class Mortality{
  static String queryGetALlMortalityOfBroodstockSub(String idSub){
    String query = "3"+"^"+"SELECT \"IDBroodstockMortality\" as \"att1\" ,\"SignOfDiseases\" as \"att2\", \n" +
        " \"DetectingTime\" as \"att3\"\n" +
        " FROM \"Tbl_BroodstockMortality\"\n" +
        " WHERE \"IDBroodstockSubBatch\" = '$idSub'\n" +
        "ORDER BY \"DetectingTime\" DESC";
    return query;
  }
  static String queryRecordMortalityBroodStock(String idSub, String datetime, String sign, int collecting,String staff){
    String query = "select procCreateNewMortality ('$idSub','$datetime','$sign','$collecting','$staff')";
    return query;
  }
  static String queryGetInFoOfBroodstockMortality(String idMor){
    String query = "13" + "^" +"SELECT \"Tbl_BroodstockMortality\".\"IDBroodstockMortality\" as \"att1\", \"Tbl_BroodstockDiscard\".\"IDBroodstockDiscard\" as \"att2\",\n" +
        "\"SignOfDiseases\" as \"att3\", \"DetectingTime\" as \"att4\", \"SampleCollecting\" as \"att5\", \"IDTreatment\" as \"att6\",\n" +
        "\"DiscardTime\" as \"att7\", \"Reason\" as \"att8\", \"Note\" as \"att9\",\"NumOfDead_Male\" as \"att10\",\"NumOfDead_Female\" as \"att11\",\n" +
        "\"Tbl_BroodstockSubBatch\".\"MaleBroodstock\" as \"att12\",\"Tbl_BroodstockSubBatch\".\"FemaleBroodstock\" as \"att13\"\n" +
        "FROM \"Tbl_BroodstockSubBatch\" ,(\"Tbl_BroodstockMortality\"\n" +
        "LEFT JOIN \"Tbl_BroodstockDiscard\" \n" +
        "ON \"Tbl_BroodstockMortality\".\"IDBroodstockMortality\" = \"Tbl_BroodstockDiscard\".\"IDBroodstockMortality\")\n" +
        "WHERE \"Tbl_BroodstockMortality\".\"IDBroodstockMortality\" = '$idMor' AND \n" +
        "\"Tbl_BroodstockSubBatch\".\"IDBroodstockSubBatch\" = \"Tbl_BroodstockMortality\".\"IDBroodstockSubBatch\"";
    return query;
  }
  static String queryBroodstockDiscard(String idMor, int male,int female, String reason, String note,String discardTime,String staff){
    String query = "select procBroodstockDiscard ('$idMor','$male','$female','$reason','$note','$discardTime','$staff')";
    return query;
  }
}