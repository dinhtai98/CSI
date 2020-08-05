class Postlarvea{
  static String queryGetSubBatchOfPostLarvea(String idSub){
    String query = "3"+"^"+"SELECT \"CurrentNumOfPostlarvea_Havest\" as \"att1\", \"HavestDate\" as \"att2\",\n" +
        "\"IDPrepostlarvea\" as \"att3\"\n" +
        "FROM \"Tbl_PostlarveaHavest\", \"Tbl_NaupliiSBMetamorphosis\"\n" +
        "WHERE \"Tbl_PostlarveaHavest\".\"IDNauplliSubBatch\" = \n" +
        "\"Tbl_NaupliiSBMetamorphosis\".\"IDNaupliiSubBatch\" AND\n" +
        "\"Tbl_NaupliiSBMetamorphosis\".\"IDStageMetamorphosis\" = 'P1' AND\n" +
        "\"Tbl_PostlarveaHavest\".\"IDNauplliSubBatch\" = '$idSub'";
    return query;
  }
  static String queryGetAllFarmer = "2 ^ SELECT \"IDFarmer\" as \"att1\", \"FarmerName\" as \"att2\"\n" +
      "FROM \"Tbl_Farmer\"";
  static String queryHistoryNumNaupliiOfPostlarvea(String idSub){
    String query = "2"+"^"+"SELECT * FROM get_history_num_nauplii_of_postlarvea('$idSub')";
    return query;
  }
  static String queryGetHistoryOfPostLarvea(String idSub){
    String query = "4"+"^"+"SELECT * FROM get_history_of_postlarvea('$idSub')";
    return query;
  }
  static String queryInfoHavest(String idSub){
    String s = "4"+"^"+"SELECT \"NumOfPostlarvea_HavestExpection\" as \"att1\", \"HavestExpectionDate\" as \"att2\",\n" +
        "\"NumOfPostlarvea_Havest\" as \"att3\", \"HavestDate\" as \"att4\"\n" +
        "FROM \"Tbl_PostlarveaHavest\"\n" +
        "WHERE \"IDNauplliSubBatch\" = '$idSub'";
    return s;
  }
  static String queryGetListPostlarveaSell(String idPre, String idSender){
    String query = "6"+"^"+"SELECT \"IDPostlarveaContract\" as \"att1\", \"NumOfPostlarvea\" as \"att2\", \n" +
        "\"PostlarveaStage\" as \"att3\", \"AssignContractTime\" as \"att4\",\"IDHatcheryReciever\" as \"att6\", (CASE\n" +
        "WHEN \"p3\".\"IDHatcheryReciever\" IS NULL THEN \n" +
        "(SELECT \"Tbl_Farmer\".\"FarmerName\" FROM \"Tbl_Farmer\", \"Tbl_PostlarveaContract\" as \"p1\" \n" +
        "WHERE \"Tbl_Farmer\".\"IDFarmer\" = \"p1\".\"IDFarmer\" AND \"p1\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "WHEN \"p3\".\"IDFarmer\" IS NULL THEN \n" +
        "(SELECT \"Tbl_HatcheryNew\".\"HatcheryName\" FROM \"Tbl_HatcheryNew\", \"Tbl_PostlarveaContract\" as \"p2\" \n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"p2\".\"IDHatcheryReciever\" AND \"p2\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "END) as \"att5\"\n" +
        "FROM \"Tbl_PostlarveaContract\" as \"p3\"\n" +
        "WHERE \"IDPrepostlarvea\" = '$idPre' AND \"Internal_External\" = '2' AND \"IDHatcherySender\" = '$idSender'\n" +
        "ORDER BY \"AssignContractTime\" DESC,  \"IDPostlarveaContract\"  DESC";
    return query;
  }
  static String querySellPostlarvea(String idSub,int num, String sender, String hatReceiver, String datetime, String note, String idPre,
      String stage, String idFarmer, String staff, String expectedDeliDate,String bonus){
    String query = "";

    if (hatReceiver == "null")
      query = "1^select * from procSellPostLarveaContractreturn ('$idSub','$num','$sender',null,'$datetime','$note','$idPre',"
          "'$stage','$idFarmer','$staff','$expectedDeliDate','$bonus')";
    else
      query = "1^select * from procSellPostLarveaContractreturn ('$idSub','$num','$sender','$hatReceiver','$datetime','$note',"
          "'$idPre','$stage',null,'$staff','$expectedDeliDate','$bonus')";
    return query;
  }
  static String querySellPostlarveaFromContract(String idCon,int num, String sender, String idReceiver, String datetime, String note,
      String stage, String idFarmer, String staff, String expectedDeliDate,String bonus){
    String query = "";
    print(idCon);
    print(num);
    print(sender);
    print(idReceiver);
    print(datetime);
    print(note);
    print(stage);
    print(idFarmer);
    print(staff);
    print(expectedDeliDate);
    print(bonus);
    if (idReceiver == "null")
      query = "1^select procsellpostlarveacontractfromcontractreturn('$idCon','$num','$sender',null,'$datetime','$note','$stage','$idFarmer','$staff','$expectedDeliDate','$bonus') as \"att1\" ";
    else
      query = "1^select procsellpostlarveacontractfromcontractreturn('$idCon','$num','$sender','$idReceiver','$datetime','$note','$stage',null,'$staff','$expectedDeliDate','$bonus') as \"att1\" ";
    return query;
  }
  static String queryGetAllPostlarveaContractBuyOfHatchery(String idHatchery, String date){
    String dateValue = 'IS NOT NULL';
    if(date != '')
      dateValue = "= '$date'";
    String query = "2"+"^"+"Select \"IDPostlarveaContract\" as \"att1\", \"AssignContractTime\" as \"att2\"\n" +
        "from \"Tbl_PostlarveaContract\"\n" +
        "WHERE \"Internal_External\" = 2 AND \"IDHatcheryReciever\" = '$idHatchery' AND\n"+
        "CAST(\"AssignContractTime\" AS DATE) $dateValue\n" +
        "ORDER BY \"AssignContractTime\" DESC";
    return query;
  }
  static String queryGetAllPostlarveaContractSellOfHatchery(String idHatchery, String date){
    String dateValue = 'IS NOT NULL';
    if(date != '')
      dateValue = "= '$date'";
    String query = "2"+"^"+"SELECT \"IDPostlarveaContract\" as \"att1\",\n" +
        "\"AssignContractTime\" as \"att2\"\n" +
        "FROM \"Tbl_PostlarveaContract\"\n" +
        "WHERE \"Internal_External\" = '2' AND \"IDHatcherySender\" = '$idHatchery' AND\n" +
        "CAST(\"AssignContractTime\" AS DATE) $dateValue\n" +
        "ORDER BY \"AssignContractTime\" DESC ";
    return query;
  }
  static String queryGetHistoryOfPostLarveaFromPostlarveaContract(String idCon){
    String query = "4"+"^"+"SELECT * FROM get_history_of_postlarvea_from_postlarvea_contract('$idCon')";
    return query;
  }
  static String queryGetOriginalNumNaupliiFromPostContract(String idPostContract){
    String query = "2"+"^"+"SELECT \"NumOfNaupliiSubBatch\" as \"att1\", \"AssignTankTime\" as \"att2\"\n" +
        "FROM \"Tbl_PostlarveaContract\", \"Tbl_NaupliiSBMetamorphosis\", \"Tbl_NaupliiSubBatch\"\n" +
        "WHERE \"Tbl_PostlarveaContract\".\"IDPrepostlarvea\" = \"Tbl_NaupliiSBMetamorphosis\".\"IDPrepostlarvea\" AND\n" +
        "\"Tbl_NaupliiSBMetamorphosis\".\"IDNaupliiSubBatch\" = \"Tbl_NaupliiSubBatch\".\"IDNaupliiSubBatch\" AND\n" +
        "\"Tbl_PostlarveaContract\".\"IDPostlarveaContract\" = '$idPostContract'";
    return query;
  }
  static String queryGetListPostlarveaContractSellFromContract(String idPreviousContract){
    String query = "6"+"^"+"SELECT \"IDPostlarveaContract\" as \"att1\", \"NumOfPostlarvea\" as \"att2\", \n" +
        "\"PostlarveaStage\" as \"att3\", \"AssignContractTime\" as \"att4\",\"IDHatcheryReciever\" as \"att6\", (CASE\n" +
        "WHEN \"p3\".\"IDHatcheryReciever\" IS NULL THEN \n" +
        "(SELECT \"Tbl_Farmer\".\"FarmerName\" FROM \"Tbl_Farmer\", \"Tbl_PostlarveaContract\" as \"p1\" \n" +
        "WHERE \"Tbl_Farmer\".\"IDFarmer\" = \"p1\".\"IDFarmer\" AND \"p1\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "WHEN \"p3\".\"IDFarmer\" IS NULL THEN \n" +
        "(SELECT \"Tbl_HatcheryNew\".\"HatcheryName\" FROM \"Tbl_HatcheryNew\", \"Tbl_PostlarveaContract\" as \"p2\" \n" +
        "WHERE \"Tbl_HatcheryNew\".\"IDHatchery\" = \"p2\".\"IDHatcheryReciever\" AND \"p2\".\"IDPostlarveaContract\" = \"p3\".\"IDPostlarveaContract\")\n" +
        "END) as \"att5\"\n" +
        "FROM \"Tbl_PostlarveaContract\" as \"p3\"\n" +
        "WHERE \"PreviousIDContract\" = '$idPreviousContract'\n" +
        "ORDER BY \"AssignContractTime\" DESC, length(\"IDPostlarveaContract\") DESC, \"IDPostlarveaContract\"  DESC";
    return query;
  }
}