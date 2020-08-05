class Contract{
  static String queryGetAllImportContractHatchery(String idHat){
    String query = "18^Select \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\",\"IDHatchery\" as \"att2\", \"IDBroodstockTrader\" as \"att3\", \n" +
        "\"IDBroodstockProducer\" as \"att4\", \"ContractSignDateTime\" as \"att5\",\"ExpectedDeliveryDate\" as \"att6\", \n" +
        "\"ArrivalPort\" as \"att7\", \"ArrivalTimePort\" as \"att8\",\"ArrivalTimeHatchery\" as \"att9\", \n" +
        "\"MoneyTransferDate\" as \"att10\", \"ViaBank\" as \"att11\", \"WiringNumber\" as \"att12\", \n" +
        "\"TransferAmount\" as \"att13\", \"TotalAmount\" as \"att14\", \"IDStepProcess\" as \"att15\", \n" +
        "\"IDRequestContract\" as \"att16\",\"IDHatcheryStaff\" as \"att17\", \"IDBroodstockBatch\" as \"att18\" \n" +
        "from \"Tbl_BroodstockImportContract\", \"Tbl_BroodstockBatch\" \n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_BroodstockBatch\".\"IDBroodstockContract\" AND\n" +
        "\"IDHatchery\" = '$idHat'\n" +
        "ORDER BY \"ContractSignDateTime\" DESC, \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" DESC";
    return query;
  }
  static String queryGetImportContractHatcheryFilterDate(String idHat, String date){
    String query = "18" + "^" + "Select \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\",\"IDHatchery\" as \"att2\", \"IDBroodstockTrader\" as \"att3\", \n" +
        "\"IDBroodstockProducer\" as \"att4\", \"ContractSignDateTime\" as \"att5\",\"ExpectedDeliveryDate\" as \"att6\", \n" +
        "\"ArrivalPort\" as \"att7\", \"ArrivalTimePort\" as \"att8\",\"ArrivalTimeHatchery\" as \"att9\", \n" +
        "\"MoneyTransferDate\" as \"att10\", \"ViaBank\" as \"att11\", \"WiringNumber\" as \"att12\", \n" +
        "\"TransferAmount\" as \"att13\", \"TotalAmount\" as \"att14\", \"IDStepProcess\" as \"att15\", \n" +
        "\"IDRequestContract\" as \"att16\",\"IDHatcheryStaff\" as \"att17\", \"IDBroodstockBatch\" as \"att18\" \n" +
        "from \"Tbl_BroodstockImportContract\", \"Tbl_BroodstockBatch\" \n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_BroodstockBatch\".\"IDBroodstockContract\" AND\n" +
        "\"IDHatchery\" = '$idHat' AND CAST(\"ContractSignDateTime\" AS DATE) = '$date' \n" +
        "ORDER BY \"ContractSignDateTime\" DESC, \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" DESC";
    return query;
  }
  static String queryGetProcessOfImportContract(String IDCon){
    String query = "4" + "^" + "SELECT \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\", \n" +
        "\"Tbl_CustomClearance\".\"IDBroodstockContract\" as \"att2\",\n" +
        " \"Tbl_DAHClearance\".\"IDBroodstockContract\" as \"att3\",\n" +
        "\"Tbl_QuarantineClearance\".\"QuarantineStatus\" as \"att4\"\n" +
        "FROM \"Tbl_BroodstockImportContract\" \n" +
        "LEFT JOIN \"Tbl_CustomClearance\" ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_CustomClearance\".\"IDBroodstockContract\"\n" +
        "LEFT JOIN \"Tbl_DAHClearance\" ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_DAHClearance\".\"IDBroodstockContract\"\n" +
        "LEFT JOIN \"Tbl_QuarantineClearance\" ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_QuarantineClearance\".\"IDBroodstockContract\"\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$IDCon'";
    return query;
  }
  static String queryGetInfoImportContract(String idCon){
    String query = "25^Select \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\", \"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att3\",\n" +
        "\"Tbl_BroodstockProducer\".\"BroodstockProducerName\" as \"att4\", \"ContractSignDateTime\" as \"att5\",\"ExpectedDeliveryDate\" as \"att6\",\n" +
        "\"ArrivalPort\" as \"att7\", \"ArrivalTimePort\" as \"att8\",\"ArrivalTimeHatchery\" as \"att9\",\n" +
        "\"MoneyTransferDate\" as \"att10\", \"ViaBank\" as \"att11\", \"WiringNumber\" as \"att12\",\n" +
        "\"TransferAmount\" as \"att13\", \"TotalAmount\" as \"att14\",\n" +
        "\"Tbl_User\".\"FullName\" as \"att15\",\n" +
        "\"BroodstockSpecies\" as \"att16\",\"BroodstockTypes\" as \"att17\", \"UnitPrice\" as \"att18\",\n" +
        "\"NumberOfPair\" as \"att19\", \"Bonus\" as \"att20\", \n" +
        "\"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" as \"att21\",\n" +
        "\"Tbl_BroodStockProducerHatcheryRanking\".\"IDBroodStockImportContract\" as \"att22\",\n" +
        "\"Tbl_BroodStockProducerDFISHRanking\".\"IDBroodStockImportContract\" as \"att23\"\n" +
        "from \"Tbl_HatcheryNew\", \"Tbl_BroodstockTrader\", \"Tbl_BroodstockProducer\", \n" +
        "\"Tbl_BroodstockBatch\",\"Tbl_BroodstockImportContract\" LEFT JOIN \n" +
        "\"Tbl_BroodStockProducerHatcheryRanking\"  ON \n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \n" +
        "\"Tbl_BroodStockProducerHatcheryRanking\".\"IDBroodStockImportContract\" LEFT JOIN\n" +
        "\"Tbl_BroodStockProducerDFISHRanking\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \n" +
        "\"Tbl_BroodStockProducerDFISHRanking\".\"IDBroodStockImportContract\" LEFT JOIN \n" +
        "\"Tbl_User\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDHatcheryStaff\" = \"Tbl_User\".\"IDUser\" \n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockProducer\" = \"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" AND\n" +
        "\"Tbl_BroodstockBatch\".\"IDBroodstockContract\" = \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryGetInfoCustomClearanceOfImportContract(String idCon){
    String query = "4" + "^" + "SELECT \"IDBroodstockContract\" as \"att1\",\n" +
        "\"Tbl_User\".\"FullName\" as \"att2\",\n" +
        "\"CustomClearanceDate\" as \"att3\", \"PhotoOfCustomCertification\" as \"att4\"\n" +
        "FROM \"Tbl_CustomClearance\", \"Tbl_User\"\n" +
        "WHERE \"Tbl_User\".\"IDUser\" = \"Tbl_CustomClearance\".\"IDHatcheryStaff\" AND\n" +
        "\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryGetInFoDAHClearanceOfImportContract(String idCon){
    String query = "5" + "^" + "SELECT \"IDBroodstockContract\" as \"att1\",\n" +
        "\"Tbl_User\".\"FullName\" as \"att2\",\n" +
        "\"ApproveStatus\" as \"att3\", \"DAHApproveDate\" as \"att4\", \"PhotoOfDAHApprove\" as \"att5\"\n" +
        "FROM \"Tbl_DAHClearance\", \"Tbl_User\"\n" +
        "WHERE \"Tbl_User\".\"IDUser\" = \"Tbl_DAHClearance\".\"IDDAHStaff\" AND\n" +
        "\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryGetInfoOfDARDQuarantine(String idCon) {
    String query = "3" + "^" + "SELECT \"IDBroodstockContract\" as \"att1\", \n" +
        "\"Tbl_User\".\"FullName\" as \"att2\",\n" +
        "\"StartingQuarantineTime\"  as \"att3\"\n" +
        "FROM \"Tbl_QuarantineClearance\", \"Tbl_User\" \n" +
        "WHERE \"Tbl_QuarantineClearance\".\"IDDARDStaffQuarantine\" = \"Tbl_User\".\"IDUser\" AND\n" +
        "\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryGetInfoOfDARDClearance(String idCon) {
    String query = "6" + "^" + "SELECT \"IDBroodstockContract\" as \"att1\", \n" +
        "\"dard1\".\"FullName\" as \"att2\",\n" +
        "\"StartingQuarantineTime\"  as \"att3\", \"QuarantineStatus\"  as \"att4\", \n" +
        "\"ClearanceTime\" as \"att5\", \"dard2\".\"FullName\" as \"att6\"\n" +
        "FROM \"Tbl_QuarantineClearance\", \"Tbl_User\" as \"dard1\", \"Tbl_User\" as \"dard2\"\n" +
        "WHERE \"Tbl_QuarantineClearance\".\"IDDARDStaffQuarantine\" = \"dard1\".\"IDUser\" AND\n" +
        "\"Tbl_QuarantineClearance\".\"IDDARDStaffClearance\" = \"dard2\".\"IDUser\" AND\n" +
        "\"IDBroodstockContract\" = '$idCon'";
    return query;
  }
  static String queryGetBatchOFImportContact(String idContract){
    String query = "9" + "^" + "Select \"IDBroodstockBatch\" as \"att1\",\"IDBroodstockContract\" as \"att2\", \"BroodstockSpecies\" as \"att3\", \n" +
        "\"BroodstockTypes\" as \"att4\", \"NumberOfPair\" as \"att5\",\"UnitPrice\" as \"att6\",  \n" +
        "\"Bonus\" as \"att7\", \"CurrentMaleBroodstock\" as \"att8\", \"CurrentFemaleBroodstock\" as \"att9\"  \n" +
        "from \"Tbl_BroodstockBatch\"\n" +
        "WHERE \"IDBroodstockContract\" = '$idContract'";
    return query;
  }
  static String queryGetInfoOfAssignContract(String idAssign){
    String query = "6"+"^"+"Select \"IDBroodstockAssignContract\" as \"att1\",\"BroodstockSpecies\" as \"att2\", \n" +
        "\"BroodstockTypes\" as \"att3\",\"CurrentMale\" as \"att4\", \"CurrentFemale\" as \"att5\"  ,\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" as \"att6\" " +
        "from \"Tbl_BroodstockBatch\", \"Tbl_BroodstockAssignContract\" \n" +
        "WHERE \"Tbl_BroodstockBatch\".\"IDBroodstockBatch\" = \"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" = '$idAssign'";
    return query;
  }
  static String queryGetListAssignToTankOfImportContract(String idBatch, String idHatchery){
    String query = "5"+"^"+"SELECT \"Tbl_BroodstockSubBatch\".\"IDBroodstockSubBatch\" as \"att1\",\n" +
        "\"Tbl_TankNew\".\"TankName\" as \"att2\", \"AssignTankTime\" as \"att3\", \n" +
        "\"Tbl_ProductionUnitNew\".\"NameProductionUnit\" as \"att4\",\n" +
        "\"Tbl_ProductionClusterNew\".\"NameOfCluster\" as \"att5\"\n" +
        "FROM \"Tbl_BroodstockSubBatch\", \"Tbl_BroodstockAssignContract\", \n" +
        "\"Tbl_TankNew\", \"Tbl_ProductionUnitNew\", \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"Tbl_BroodstockSubBatch\".\"IDBroodstockAssignContract\" = \"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"Internal_External\" = '1' AND \n" +
        "\"Tbl_TankNew\".\"IDTank\" = \"Tbl_BroodstockSubBatch\".\"IDTank\" AND\n" +
        "\"Tbl_TankNew\".\"IDProductionUnit\" = \"Tbl_ProductionUnitNew\".\"IDProductionUnit\" AND\n" +
        "\"Tbl_ProductionUnitNew\".\"IDProductionCluster\" = \"Tbl_ProductionClusterNew\".\"IDCluster\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" = '$idBatch' AND \n" +
        "\"Tbl_BroodstockAssignContract\".\"IDHatcheryReciver\" = '$idHatchery'\n" +
        "ORDER BY \"AssignTankTime\" DESC";
    return query;
  }
  static String queryGetListSellOfImportContract(String IDBatch, String IDHatchery){
    String query = "3"+"^"+"SELECT \"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" as \"att1\",\n" +
        "\"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\", \"AssignContractDate\" as \"att3\"\n" +
        "FROM \"Tbl_BroodstockAssignContract\", \"Tbl_HatcheryNew\" \n" +
        "WHERE \"Tbl_BroodstockAssignContract\".\"IDHatcheryReciver\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Internal_External\" = '2' AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" = '$IDBatch' " +
        "AND \"Tbl_BroodstockAssignContract\".\"IDHatcherySender\" = '$IDHatchery'\n" +
        "ORDER BY \"AssignContractDate\" DESC, \"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" DESC";
    return query;
  }
  static String queryDAHGetImportContract(String idContract){
    String query = "10" + "^" + "SELECT \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" as \"att1\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\",\n" +
        "\"Tbl_BroodstockProducer\".\"BroodstockProducerName\" as \"att3\", \"Tbl_BroodstockTrader\".\"BroodstockTraderName\" as \"att4\", \n" +
        "\"BroodstockSpecies\" as \"att5\", \"BroodstockTypes\" as \"att6\", \"UnitPrice\" as \"att7\", \"NumberOfPair\" as \"att8\", \n" +
        "\"Bonus\" as \"att9\", \"Tbl_DAHClearance\".\"IDBroodstockContract\" as \"att10\"\n" +
        "FROM \"Tbl_BroodstockBatch\", \"Tbl_HatcheryNew\", \"Tbl_BroodstockProducer\", \"Tbl_BroodstockTrader\",\n" +
        "(\"Tbl_BroodstockImportContract\" LEFT JOIN  \"Tbl_DAHClearance\"\n" +
        "ON \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_DAHClearance\".\"IDBroodstockContract\")\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = \"Tbl_BroodstockBatch\".\"IDBroodstockContract\" AND \n" +
        "\"Tbl_BroodstockImportContract\".\"IDHatchery\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockProducer\" = \"Tbl_BroodstockProducer\".\"IDBroodstockProducer\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockTrader\" = \"Tbl_BroodstockTrader\".\"IDBroodstockTrader\" AND\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idContract'";
    return query;
  }
  static String queryHatcheryRankingContract(String idSeller, String idBuyer, String idCon, int ranking, String comment){
    String query = "select procinserttbl_hatcherybuyerranking('$idSeller','$idBuyer','$idCon','$ranking','$comment')";
    return query;
  }
  static String queryHatcheryRankingProducer(String idPro, String idBuyer, String idCon, int ranking, String comment){
    String query = "select proccontract_hatcheryrankingproducer('$idPro','$idBuyer','$idCon','$ranking','$comment')";
    return query;
  }

  static String queryGetInfoOfBroodstockContractBuy(String idAssignContract){
    String query = "17"+"^"+"SELECT \"IDBroodstockAssignContract\" as \"att1\",\n" +
        "\"AssignContractDate\" as \"att2\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att3\", \n" +
        "\"BroodstockSpecies\" as \"att4\", \"BroodstockTypes\" as \"att5\",\n" +
        "\"Tbl_BroodstockAssignContract\".\"NumberOfPair\" as \"att6\",\n" +
        "\"CurrentMale\" as \"att7\", \"CurrentFemale\" as \"att8\",\n" +
        "\"ExpectedDeliveryDate\" as \"att9\", \"MoneyTransferDate\" as \"att10\",\n" +
        "\"TotalAmount\" as \"att11\", \"TransferAmount\" as \"att12\", \n" +
        "\"Tbl_BroodstockAssignContract\".\"Bonus\" as \"att13\",\n" +
        "\"IDHatcherySender\" as \"att14\", \"IDHatcheryReciver\" as \"att15\",\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\" as \"att16\"\n" +
        "FROM \"Tbl_BroodstockBatch\", \"Tbl_HatcheryNew\",\"Tbl_BroodstockAssignContract\"\n" +
        "LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        "\"IDBroodstockAssignContract\" = \"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" = \"Tbl_BroodstockBatch\".\"IDBroodstockBatch\" AND\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDHatcherySender\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"IDBroodstockAssignContract\" = '$idAssignContract'";
    return query;
  }
  static String queryGetInfoOfBroodstockContractSell(String idAssignContract){
    String query = "15"+"^"+"SELECT \"IDBroodstockAssignContract\" as \"att1\", \"AssignContractDate\" as \"att2\",\n" +
        "\"buyer\".\"HatcheryName\" as \"att3\", \"Tbl_BroodstockBatch\".\"BroodstockSpecies\" as \"att4\",\n" +
        "\"Tbl_BroodstockBatch\".\"BroodstockTypes\" as \"att5\", \"ExpectedDeliveryDate\" as \"att6\",\n" +
        "\"MoneyTransferDate\" as \"att7\", \"ViaBank\" as \"att8\", \"WiringNumber\" as \"att9\",\n" +
        "\"TotalAmount\" as \"att10\", \"TransferAmount\" as \"att11\",\n" +
        "\"Tbl_BroodstockAssignContract\".\"NumberOfPair\" as \"att12\", \n" +
        "\"Tbl_BroodstockAssignContract\".\"Bonus\" as \"att13\",\n" +
        "\"Tbl_User\".\"FullName\"  as \"att14\",\n" +
        "\"IDTransporter\" as \"att15\"\n" +
        "FROM \"Tbl_BroodstockBatch\", \"Tbl_User\", \"Tbl_HatcheryNew\" as \"buyer\",\n" +
        "\"Tbl_BroodstockAssignContract\" LEFT JOIN \"Tbl_ContractTransport\" ON\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" = \"Tbl_ContractTransport\".\"IDContract\"\n" +
        "WHERE \"Tbl_BroodstockAssignContract\".\"IDBroodstockBatch\" = \"Tbl_BroodstockBatch\".\"IDBroodstockBatch\" AND\n" +
        "\"buyer\".\"IDHatchery\" = \"Tbl_BroodstockAssignContract\".\"IDHatcheryReciver\" AND\n" +
        "\"Tbl_User\".\"IDUser\" = \"Tbl_BroodstockAssignContract\".\"IDHatcheryStaff\" AND\n" +
        "\"Internal_External\" = 2 AND \"IDBroodstockAssignContract\" = '$idAssignContract'";
    return query;
  }
  static String queryGetInfoOfNaupliiContractBuy(String idNaupliiContract){
    String s = "11"+"^"+"SELECT \"IDNaupliiContract\" as \"att1\",\n" +
        "\"SignContractTime\" as \"att2\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att3\",\n" +
        "\"NumOfNauplii\" as \"att4\", \"CurrentNauplii\" as \"att5\",\"Bonus\" as \"att6\",\n" +
        "\"ExpectedDeliveryDate\" as \"att7\", \"Note\" as \"att8\",\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\" as \"att9\",\n" +
        "\"IDHatcherySender\" as \"att10\", \"IDHatcheryReciever\" as \"att11\"\n" +
        "FROM \"Tbl_HatcheryNew\",\"Tbl_NaupliiContract\" LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        " \"IDNaupliiContract\" = \"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"IDNaupliiContract\" = '$idNaupliiContract' AND\n" +
        "\"Tbl_NaupliiContract\".\"IDHatcherySender\" = \"Tbl_HatcheryNew\".\"IDHatchery\"";
    return s;
  }
  static String queryGetInfoOfNaupliiContractSell(String idNaupliiContract){
    String s = "9"+"^"+"SELECT \"IDNaupliiContract\" as \"att1\", \"SignContractTime\" as \"att2\",\n" +
        "\"Tbl_HatcheryNew\".\"HatcheryName\" as \"att3\", \"NumOfNauplii\" as \"att4\",\n" +
        "\"Note\" as \"att5\", \"ExpectedDeliveryDate\" as \"att6\",\"Bonus\" as \"att7\",\n" +
        "\"Tbl_User\".\"FullName\"  as \"att8\",\n" +
        "\"IDTransporter\" as \"att9\"\n" +
        "FROM  \"Tbl_HatcheryNew\", \"Tbl_User\",\n" +
        "\"Tbl_NaupliiContract\" LEFT JOIN \"Tbl_ContractTransport\" ON \n" +
        "\"Tbl_NaupliiContract\".\"IDNaupliiContract\" = \"Tbl_ContractTransport\".\"IDContract\" \n" +
        "WHERE \"Tbl_NaupliiContract\".\"IDHatcheryReciever\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"Tbl_User\".\"IDUser\" = \"Tbl_NaupliiContract\".\"IDHatcheryStaff\" AND\n" +
        "\"Internal_External\" = 2 AND \"IDNaupliiContract\" = '$idNaupliiContract'";
    return s;
  }
  static String queryGetInfoOfPostlarveaContractBuy(String idPostContract){
    String s = "12"+"^"+"SELECT \"IDPostlarveaContract\" as \"att1\",\n" +
        "\"AssignContractTime\" as \"att2\", \"Tbl_HatcheryNew\".\"HatcheryName\" as \"att3\",\n" +
        "\"NumOfPostlarvea\" as \"att4\", \"CurrentPostlarvea\" as \"att5\",\"Bonus\" as \"att6\",\n" +
        "\"ExpectedDeliveryDate\" as \"att7\", \"Note\" as \"att8\",\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\" as \"att9\",\n" +
        "\"IDHatcherySender\" as \"att10\", \"IDHatcheryReciever\" as \"att11\",\"PostlarveaStage\" as \"att12\" \n" +
        "FROM \"Tbl_HatcheryNew\",\"Tbl_PostlarveaContract\" LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        " \"IDPostlarveaContract\" = \"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"IDPostlarveaContract\" = '$idPostContract' AND\n" +
        "\"Tbl_PostlarveaContract\".\"IDHatcherySender\" = \"Tbl_HatcheryNew\".\"IDHatchery\"";
    return s;
  }
  static String queryGetInfoOfPostlarveaContractSell(String idPostContract){
    String query = "11" + "^" + "SELECT \"IDPostlarveaContract\" as \"att1\", \"AssignContractTime\" as \"att2\", \n" +
        "\"NumOfPostlarvea\" as \"att3\", \"PostlarveaStage\" as \"att4\",(CASE\n" +
        "WHEN \"p3\".\"IDHatcheryReciever\" IS NULL THEN \n" +
        "(SELECT \"Tbl_Farmer\".\"FarmerName\" FROM \"Tbl_Farmer\", \"Tbl_PostlarveaContract\" as \"p1\" \n" +
        "WHERE \"Tbl_Farmer\".\"IDFarmer\" = \"p1\".\"IDFarmer\" AND \"p1\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "WHEN \"p3\".\"IDFarmer\" IS NULL THEN \n" +
        "(SELECT \"Tbl_HatcheryNew\".\"HatcheryName\" FROM \"Tbl_HatcheryNew\", \"Tbl_PostlarveaContract\" as \"p2\" \n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"p2\".\"IDHatcheryReciever\" AND \"p2\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "END) as \"att5\", \"Note\" as \"att6\", \"IDHatcheryReciever\" as \"att7\", \n" +
        "\"ExpectedDeliveryDate\" as \"att8\",\"Bonus\" as \"att9\",\n" +
        "\"Tbl_User\".\"FullName\"  as \"att10\",\n" +
        "\"IDTransporter\" as \"att11\"\n" +
        "FROM \"Tbl_User\",\"Tbl_PostlarveaContract\" as \"p3\" \n" +
        "LEFT JOIN \"Tbl_ContractTransport\" ON p3.\"IDPostlarveaContract\" = \"Tbl_ContractTransport\".\"IDContract\" \n" +
        "WHERE \"Tbl_User\".\"IDUser\" = p3.\"IDHatcheryStaff\" AND \n" +
        "\"IDPostlarveaContract\" = '$idPostContract'";
    return query;
  }
}