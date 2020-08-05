class Nauplii{
  static String queryGetSubBatchOfNauplii(String idSub){
    String query = "3"+"^"+"SELECT \"NumOfNaupliiSubBatch\" as \"att1\", \"AssignTankTime\" as \"att2\",\n" +
        "\"Tbl_PostlarveaHavest\".\"HavestExpectionDate\" as \"att3\"\n" +
        "FROM \"Tbl_NaupliiSubBatch\", \"Tbl_PostlarveaHavest\"\n" +
        "WHERE \"Tbl_NaupliiSubBatch\".\"IDNaupliiSubBatch\" = \"Tbl_PostlarveaHavest\".\"IDNauplliSubBatch\" AND\n" +
        "\"IDNaupliiSubBatch\" = '$idSub'";
    return query;
  }
  static String queryInfoStagesOfNaplii(String idSub){
    String query = "4"+"^"+"SELECT \"Tbl_StageMetamorphosis\".\"StageMetamorphosis\" as \"att1\","
        " \"Tbl_NaupliiSBMetamorphosis\".\"IDStageMetamorphosis\" as \"att2\",\n" +
        "\"NumOfMetamorphosis\" as \"att3\", \"RecordDate\" as \"att4\"\n" +
        "FROM (\"Tbl_StageMetamorphosis\"\n" +
        "LEFT JOIN \"Tbl_NaupliiSBMetamorphosis\" \n" +
        "ON \"Tbl_StageMetamorphosis\".\"IDStageMetamorphosis\" = \"Tbl_NaupliiSBMetamorphosis\".\"IDStageMetamorphosis\" AND\n" +
        "\"Tbl_NaupliiSBMetamorphosis\".\"IDNaupliiSubBatch\" = '$idSub')";
    return query;
  }
  static String queryGetMinNumOfMetamorphosis(String idSub){
    String query = "1"+"^"+"SELECT min(\"NumOfMetamorphosis\") as \"att1\"\n" +
        "FROM \"Tbl_NaupliiSBMetamorphosis\"\n" +
        "WHERE \"IDNaupliiSubBatch\" = '$idSub'";
    return query;
  }
  static String queryRecordStageMetamorphosis(String IDSub, String IDStage, String Note,String date, int num, String staff){
    String query = "select procRecordStageMetamorphosisnew ('$IDSub','$IDStage','$Note','$date','$num','$staff')";
    return query;
  }
  static String queryGetListSalinityOfSBNauplii(String idSub){
    String query = "5"+"^"+"SELECT \"IDNaupliiSubBatch\" as \"att1\", \"InitialSalinity\" as \"att2\",\n" +
        "\"TargetSalinity\" as \"att3\", \"StartingTime\" as \"att4\", \"CompletionTime\" as \"att5\"\n" +
        "FROM \"Tbl_Salinity\"\n" +
        "WHERE \"IDNaupliiSubBatch\" = '$idSub'";
    return query;
  }
  static String queryRecordSalinity(String idSub,String initial, String target, String startDate,String compleDate,String staff){
    String query = "select proccreatesalinitynauplii ('$idSub','$initial','$target','$startDate','$compleDate','$staff')";
    return query;
  }
  static String queryGetAllNaupliiContractBuyOfHatchery(String idHatchery, String date){
    String dateValue = 'IS NOT NULL';
    if(date != '')
      dateValue = "= '$date'";
    String query = "2" + "^" + "Select \"IDNaupliiContract\" as \"att1\", \"SignContractTime\" as \"att2\"\n" +
        "from \"Tbl_NaupliiContract\"\n" +
        "WHERE \"Internal_External\" = 2 AND \"IDHatcheryReciever\" = '$idHatchery' AND \n" +
        "CAST(\"SignContractTime\" AS DATE) $dateValue\n" +
        "ORDER BY \"SignContractTime\" DESC";
    return query;
  }
  static String queryGetAllNaupliiContractSellOfHatchery(String idHatchery, String date){
    String dateValue = 'IS NOT NULL';
    if(date != '')
      dateValue = "= '$date'";
    String s = "2"+"^"+"SELECT \"IDNaupliiContract\" as \"att1\",\n" +
        "\"SignContractTime\" as \"att2\"\n" +
        "FROM \"Tbl_NaupliiContract\"\n" +
        "WHERE \"Internal_External\" = '2' AND \"IDHatcherySender\" = '$idHatchery' AND \n" +
        "CAST(\"SignContractTime\" AS DATE) $dateValue\n" +
        "ORDER BY \"SignContractTime\" DESC";
    return s;
  }
  static String queryGetListAssignTankFromNaupliiContract(String idNaupliiContract, String idHatchery){
    print(idNaupliiContract);
    print(idHatchery);
    String s = "5"+"^"+"SELECT \"Tbl_NaupliiSubBatch\".\"IDNaupliiSubBatch\" as \"att1\",\"Tbl_TankNew\".\"TankName\" as \"att2\",\n" +
        "\"AssignTankTime\" as \"att3\", \"Tbl_ProductionUnitNew\".\"NameProductionUnit\" as \"att4\",\n" +
        "\"Tbl_ProductionClusterNew\".\"NameOfCluster\" as \"att5\"\n" +
        "FROM \"Tbl_NaupliiSubBatch\", \"Tbl_NaupliiContract\", \n" +
        "\"Tbl_TankNew\", \"Tbl_ProductionUnitNew\", \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"Tbl_NaupliiSubBatch\".\"IDNaupliiContract\" = \"Tbl_NaupliiContract\".\"IDNaupliiContract\" AND\n" +
        "\"Tbl_TankNew\".\"IDTank\" = \"Tbl_NaupliiSubBatch\".\"IDTank\" AND\n" +
        "\"Tbl_TankNew\".\"IDProductionUnit\" = \"Tbl_ProductionUnitNew\".\"IDProductionUnit\" AND\n" +
        "\"Tbl_ProductionUnitNew\".\"IDProductionCluster\" = \"Tbl_ProductionClusterNew\".\"IDCluster\" AND\n" +
        "\"Tbl_NaupliiContract\".\"IDNaupliiContract\" = '$idNaupliiContract' AND \"IDHatcheryReciever\" = '$idHatchery'\n" +
        "ORDER BY \"AssignTankTime\" DESC";
    return s;
  }
  static String queryGetListNaupliiSellFromContract(String idPreviousContract){
    String query = "3"+"^"+"SELECT \"IDNaupliiContract\" as \"att1\",\"Tbl_HatcheryNew\".\"HatcheryName\" as \"att2\",\n" +
        "\"SignContractTime\" as \"att3\"\n" +
        "FROM \"Tbl_NaupliiContract\", \"Tbl_HatcheryNew\"\n" +
        "WHERE \"Tbl_NaupliiContract\".\"IDHatcheryReciever\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
        "\"PreviousIDContract\" = '$idPreviousContract'\n" +
        "ORDER BY \"SignContractTime\" DESC, \"IDNaupliiContract\" DESC";
    return query;
  }
  static String queryNaupliiAssignTankFromNaupliiContract(String idContract, int num, String idHatchery, String staff, String tank, String datetime, String harvestExpectedDate){
    String s = "SELECT public.procnaupliiassigntotankfromnaupliicontract('$idContract','$num','$idHatchery','$staff','$tank','$datetime','$harvestExpectedDate')";
    return s;
  }

  static String queryNaupliiSellFromContract(String idContract, int num, String idReceiver, String idSender, String datetime,String note, String staff, String expectedDeliDate,String bonus){
    String query = "SELECT public.procnaupliisellfromnaupliicontractreturn('$idContract','$num','$idReceiver','$idSender','$datetime','$note','$staff',2,'$expectedDeliDate','$bonus')";
    return query;
  }
}