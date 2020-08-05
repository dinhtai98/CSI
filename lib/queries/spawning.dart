class Spawning{
  static String queryInfoOfSpawning(String idSpawning){
    String query = "2" + "^" + "SELECT \"SpawningName\" as \"att1\", \"CurrentNumOfNauplii\" as \"att2\"\n" +
        "FROM \"Tbl_BroodstockSpawning\"\n" +
        "WHERE \"IDBroodstockSpawning\" = '$idSpawning'";
    return query;
  }

  static String querySpawningSell(String idSpawning, int num, String receiver,
      String sender, String datetime, String note, String staff, String expectedDate,String bonus){
    String query = "1^select * from procNaupliiSellreturn ('$idSpawning','$num','$receiver','$sender','$datetime',"
        "'$note','$staff','2','$expectedDate','$bonus')";
    return query;
  }

  static String querySpawningAssignToTank(String idSpawning, int num, String idHat, String staff,
      String idTank, String date, String expectedHarvestDate){
    String query = "select procNaupliiAssignToTank ('$idSpawning','$num','$idHat','$staff','$idTank','$date','$expectedHarvestDate')";
    return query;
  }
}