class Broodstock{

  static String queryAssignToTankBroodstock(String idBatch, int female, int male, String assignTankDate, String idTank, String staff, String idHatchery, String reason){
    String query = "select procAssignToTank ('$idBatch','$female','$male','$assignTankDate','$idTank','$staff','$idHatchery','$reason')";
    return query;
  }
  static String queryAssignToTankFromAssignContract(String idAssignContract, int female, int male,
      String datetime, String idTank, String staff, String hatchery, String reason){
    String query = "SELECT public.procassigntotankfromassigncontract('$idAssignContract','$female','$male',"
        "'$datetime','$idTank','$staff','$hatchery','$reason')";
    return query;
  }
  static String querySellBroodstock(String idReceiver, String signDate, int pair, String idBatch, String deliDate,
      String transferDate, int total, int transfer, String viaBank,
      String wiring, String idSender,String idStaff, String bonus){
    String query =  "1^select * from procInsertTbl_BroodstockAssignContract_Update_Batchreturn " +
        "('$idReceiver','$signDate','$pair','$idBatch','$deliDate','$transferDate','$total',"
            "'$transfer','$viaBank','$wiring', '$idSender', '$idStaff', '$bonus')";
    return query;
  }
  static String querySellBroodstockFromAssignContract(String idAssignContract, String idReceiver, String signDate,
      int pair, String idBatch, String deliDate,
      String transferDate, int total,int transfer, String viaBank,
      String wiring, String idSender,String idStaff,String bonus){
    String query = "1^SELECT public.procinserttbl_broodstockassigncontract_sell_return " +
        "('$idAssignContract','$idReceiver','$signDate','$pair','$idBatch','$deliDate','$transferDate',"
            "'$total','$transfer','$viaBank','$wiring', '$idSender', '$idStaff', '$bonus') as \"att1\" ";
    return query;
  }
  static String queryGetTankOfBroodstock(String idSub){
    String query = "9" + "^" + "SELECT \"BroodstockSpecies\" as \"att1\", \"BroodstockTypes\" as \"att2\", \"MaleBroodstock\" as \"att3\", \n" +
        "\"FemaleBroodstock\" as \"att4\", \"Ablation\" as \"att5\", \"AblationTime\" as \"att6\",\n" +
        "\"Tbl_User\".\"FullName\" as \"att7\", \"AssignTankTime\" as \"att8\", \n" +
        "\"Tbl_BroodstockTermination\".\"IDBroodstockTermination\" as \"att9\"\n" +
        "FROM \"Tbl_BroodstockTermination\", \"Tbl_BroodstockSubBatch\" LEFT JOIN \"Tbl_User\" ON\n" +
        "\"Tbl_User\".\"IDUser\" = \"Tbl_BroodstockSubBatch\".\"IDHatcheryStaff_Ablation\"\n" +
        "WHERE \"Tbl_BroodstockSubBatch\".\"IDBroodstockSubBatch\" = \"Tbl_BroodstockTermination\".\"IDBroodstockSubBatch\" AND\n" +
        "\"Tbl_BroodstockSubBatch\".\"IDBroodstockSubBatch\" = '$idSub'";
    return query;
  }
  static String queryListSpawning(String idSub){
    String query = "5" + "^" + "SELECT \"IDBroodstockSpawning\" as \"att1\", \"SpawningName\" as \"att2\", \"NumOfNauplii\" as \"att3\",\n" +
        "\"CurrentNumOfNauplii\" as \"att4\", \"SpawningTime\" as \"att5\" \n" +
        "FROM \"Tbl_BroodstockSpawning\"\n" +
        "WHERE \"IDBroodstockSubBatch\" = '$idSub'" +
        "ORDER BY \"SpawningTime\" DESC";
    return query;
  }
  static String queryCreateSpawning(String name, String idsub, String datetime,int num, String staff){
    String query = "select Tbl_InsertBroodstockSpawning ('$name','$idsub','$datetime','$num','$staff')";
    return query;
  }
  static String queryAblating(String IDSub, String date, String staff){
    String query = "select procSubBatch_Ablation ('$IDSub','$date','$staff')";
    return query;
  }
  static String queryGetAllBroodStockContractBuyOfHatchery(String idHatchery){
    String query = "2"+"^"+"Select \"IDBroodstockAssignContract\" as \"att1\", \"AssignContractDate\" as \"att2\"\n" +
        "from \"Tbl_BroodstockAssignContract\"\n" +
        "WHERE \"Internal_External\" = 2 AND \"IDHatcheryReciver\" = '$idHatchery'\n" +
        "ORDER BY \"AssignContractDate\" DESC ";
    return query;
  }
  static String queryGetAllBroodStockContractBuyOfHatcheryFilterDate(String idHatchery, String date){
    String query = "2"+"^"+"Select \"IDBroodstockAssignContract\" as \"att1\", \"AssignContractDate\" as \"att2\"\n" +
        "from \"Tbl_BroodstockAssignContract\"\n" +
        "WHERE \"Internal_External\" = 2 AND \"IDHatcheryReciver\" = '$idHatchery' AND\n" +
        "CAST(\"AssignContractDate\" AS DATE) = '$date'" +
        "ORDER BY \"AssignContractDate\" DESC ";
    return query;
  }
  static String queryGetAllBroodstockContractSellOfHatchery(String idHatchery){
    String query = "2"+"^"+"SELECT \"IDBroodstockAssignContract\" as \"att1\",\n" +
        "\"AssignContractDate\" as \"att2\"\n" +
        "FROM \"Tbl_BroodstockAssignContract\"\n" +
        "WHERE \"Internal_External\" = '2' AND \"IDHatcherySender\" = '$idHatchery'\n" +
        "ORDER BY \"AssignContractDate\" DESC";
    return query;
  }
  static String queryGetAllBroodstockContractSellOfHatcheryFilterDate(String idHatchery, String date){
    String query = "2"+"^"+"SELECT \"IDBroodstockAssignContract\" as \"att1\",\n" +
        "\"AssignContractDate\" as \"att2\"\n" +
        "FROM \"Tbl_BroodstockAssignContract\"\n" +
        "WHERE \"Internal_External\" = '2' AND \"IDHatcherySender\" = '$idHatchery' AND\n" +
        "CAST(\"AssignContractDate\" AS DATE) = '$date'" +
        "ORDER BY \"AssignContractDate\" DESC";
    return query;
  }
  static String queryGetListAssignTankOfAssignContract(String idAssignContract, String idHatchery){
    print(idAssignContract);
    print(idHatchery);
    String query = "5"+"^"+"SELECT \"Tbl_BroodstockSubBatch\".\"IDBroodstockSubBatch\" as \"att1\",\n" +
        "\"Tbl_TankNew\".\"TankName\" as \"att2\", \"AssignTankTime\" as \"att3\", \n" +
        "\"Tbl_ProductionUnitNew\".\"NameProductionUnit\" as \"att4\",\n" +
        "\"Tbl_ProductionClusterNew\".\"NameOfCluster\" as \"att5\"\n" +
        "FROM \"Tbl_BroodstockSubBatch\", \"Tbl_BroodstockAssignContract\", \n" +
        "\"Tbl_TankNew\", \"Tbl_ProductionUnitNew\", \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"Tbl_BroodstockSubBatch\".\"IDBroodstockAssignContract\" = \"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" AND\n" +
        "\"Tbl_TankNew\".\"IDTank\" = \"Tbl_BroodstockSubBatch\".\"IDTank\" AND\n" +
        "\"Tbl_TankNew\".\"IDProductionUnit\" = \"Tbl_ProductionUnitNew\".\"IDProductionUnit\" AND\n" +
        "\"Tbl_ProductionUnitNew\".\"IDProductionCluster\" = \"Tbl_ProductionClusterNew\".\"IDCluster\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" = '$idAssignContract' AND \n" +
        "\"Tbl_BroodstockAssignContract\".\"IDHatcheryReciver\" = '$idHatchery'\n" +
        "ORDER BY \"AssignTankTime\" DESC ";
    return query;
  }
  static String queryGetListSellOfAssignContract(String idPreviousContract){
    String query = "3"+"^"+"SELECT \"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" as \"att1\",\n" +
        "\"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\", \"AssignContractDate\" as \"att3\"\n" +
        "FROM \"Tbl_BroodstockAssignContract\", \"Tbl_HatcheryNew\" \n" +
        "WHERE \"Tbl_BroodstockAssignContract\".\"IDHatcheryReciver\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"PreviousIDContract\" = '$idPreviousContract'\n" +
        "ORDER BY \"AssignContractDate\" DESC";
    return query;
  }
}