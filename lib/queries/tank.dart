class Tank{
  static String query_GetAllClusterOfHatchery(String IDHat){
    String query = "2" + "^" + "SELECT \"IDProductionCluster\" as \"att1\", \"ClusterName\" as \"att2\"\n" +
        "FROM public.\"Tbl_ProductionCluster\"\n" +
        "WHERE \"IDHatchery\" = '$IDHat' \n" +
        "ORDER BY \"ClusterName\"";
    return  query;
  }
  static String query_GetAllKhuSXOfCSSX(String idHat){
    String query =  "2^SELECT \"IDCluster\" as \"att1\", \"NameOfCluster\" as \"att2\"\n" +
        "FROM \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"Tbl_ProductionClusterNew\".\"IDHatchery\" = '$idHat'";
    return query;
  }
  static String queryKhuSX(String idClus){
    String query =  "10^SELECT \"IDCluster\" as \"att1\", \"NameOfCluster\" as \"att2\",\n" +
        "\"Address\" as \"att3\", \"Country\" as \"att4\", \"GPS\" as \"att5\",\n" +
        "\"IDContactPerson\" as \"att6\", \"Phone\" as \"att7\", \n" +
        "\"EstablishmentYear\" as \"att8\", \"ProductionCapacity\" as \"att9\", \"NumberOfProductionUnit\" as \"att10\"\n" +
        "FROM \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"Tbl_ProductionClusterNew\".\"IDCluster\" = '$idClus'";
    return query;
  }
  static String queryGetAllNhaSXOfKhuSX(String idClus){
    String query =  "7^SELECT \"IDProductionUnit\" as \"att1\", \"NameProductionUnit\" as \"att2\",\n" +
        "\"GPS\" as \"att3\", \"YearOfEstablish\" as \"att4\", \"DesignatedFunction\" as \"att5\",\n" +
        "\"NumberOfTanks\" as \"att7\", \"TotalWorkingVolume\" as \"att7\"\n" +
        "FROM \"Tbl_ProductionUnitNew\"\n" +
        "WHERE \"Tbl_ProductionUnitNew\".\"IDProductionCluster\" = '$idClus'";
    return query;
  }
  static String queryNhaSX(String idNhaSX){
    String query =  "7^SELECT \"IDProductionUnit\" as \"att1\", \"NameProductionUnit\" as \"att2\",\n" +
        "\"GPS\" as \"att3\", \"YearOfEstablish\" as \"att4\", \"DesignatedFunction\" as \"att5\",\n" +
        "\"NumberOfTanks\" as \"att6\", \"TotalWorkingVolume\" as \"att7\"\n" +
        "FROM \"Tbl_ProductionUnitNew\"\n" +
        "WHERE \"Tbl_ProductionUnitNew\".\"IDProductionUnit\" = '$idNhaSX'";
    return query;
  }
  static String queryGetAllTankOfNhaSX(String idClus) {
    String query = "2^SELECT \"IDTank\" as \"att1\", \"TankName\" as \"att2\"\n" +
        "FROM \"Tbl_TankNew\" \n" +
        "WHERE \"IDProductionUnit\" = '$idClus'";
    return query;
  }
  static String queryGetTank(String idTank){
    String query = "8^SELECT \"IDTank\" as \"att1\", \"TankName\" as \"att2\",\"YearOfEstablish\" as \"att3\",\n" +
        "\"DesignatedFunction\" as \"att4\", \"SurfaceArea\" as \"att5\", \"WorkingVolume\" as \"att6\",\n" +
        "\"NumberOfBroodstockAble\" as \"att7\", \"NumberOfNaupliiAble\" as \"att8\"\n" +
        "FROM \"Tbl_TankNew\" \n" +
        "WHERE \"IDTank\" = '$idTank'";
    return query;
  }

  static String queryCreateKhuSX(String name, String address, String country, String yearEstablish, int capacity, int nUnit, String idHatchery){
    String query = "SELECT public.proc_createkhusx('$name', '$address', '$country', '$capacity', '$nUnit' ,'$yearEstablish', '$idHatchery')";
    return query;
  }
  static String queryCreateNhaSX(String name, int func, int ntanks, int totalVolume, String yearEstablish, String idKhuSX){
    String query = "SELECT public.proc_createnhasx('$name', '$func', '$ntanks', '$totalVolume', '$yearEstablish', '$idKhuSX')";
    return query;
  }
  static String queryCreateBe(String name, int func, int area, int totalVolume, int broodstockAble, int naupliiAble, String yearEstablish, String idNhaSX){
    String query = "SELECT public.proc_createbe('$name', '$func', '$area', '$totalVolume', '$broodstockAble', '$naupliiAble','$yearEstablish', '$idNhaSX')";
    return query;
  }
  static String queryGetAllBeOfNhaSX(String idNhaSX){
    String query = "5" + "^" + "SELECT \"IDTank\" as att1, \"TankName\" as att2, \n" +
        "\"Tbl_TankNew\".\"IDSubBatch\" as \"att3\", \"Available\" as \"att4\", \n" +
        "(SELECT \"IDPrepostlarvea\"\n" +
        " FROM \"Tbl_NaupliiSBMetamorphosis\"\n" +
        " WHERE \"Tbl_NaupliiSBMetamorphosis\".\"IDNaupliiSubBatch\" = \"Tbl_TankNew\".\"IDSubBatch\" AND \n" +
        " \"IDPrepostlarvea\" IS NOT NULL) as \"att5\"\n" +
        "FROM \"Tbl_TankNew\"\n" +
        "WHERE \"IDProductionUnit\" = '$idNhaSX'\n" +
        "ORDER BY \"TankName\"  ";
    return query;
  }
  static String queryGetClusterHasUnitHasTankOfHatchery(idHatchery){
    print("idHatchery $idHatchery");
    String query = "2^SELECT \"Tbl_ProductionClusterNew\".\"IDCluster\" as \"att1\",\n" +
        "\"Tbl_ProductionClusterNew\".\"NameOfCluster\" as \"att2\"\n" +
        "FROM \"Tbl_ProductionClusterNew\"\n" +
        "WHERE \"IDCluster\" = ANY (SELECT \"IDProductionCluster\" FROM \"Tbl_ProductionUnitNew\" \n" +
        "\t\t\t\t\t\t WHERE \"IDProductionUnit\" = ANY (SELECT \"IDProductionUnit\" FROM \"Tbl_TankNew\") AND\n" +
        "\"Tbl_ProductionClusterNew\".\"IDHatchery\" = '$idHatchery' \n" +
        "ORDER BY \"Tbl_ProductionClusterNew\".\"NameOfCluster\") ";
    return query;
  }
  static String queryGetUnitHasTankOfCluster(String idKhuSX){
    String query = "2" + "^" + "SELECT \"Tbl_ProductionUnitNew\".\"IDProductionUnit\" as \"att1\",\n" +
        "\"Tbl_ProductionUnitNew\".\"NameProductionUnit\" as \"att2\"\n" +
        "FROM \"Tbl_ProductionUnitNew\"\n" +
        "WHERE \"IDProductionUnit\" = ANY (SELECT \"IDProductionUnit\" FROM \"Tbl_TankNew\") AND\n" +
        "\"Tbl_ProductionUnitNew\".\"IDProductionCluster\" = '$idKhuSX' \n" +
        "ORDER BY \"Tbl_ProductionUnitNew\".\"NameProductionUnit\" ";
    return query;
  }
  static String queryGetAllTankEmptyOfCluster(String idNhaSX){
    String query = "2" + "^" + "SELECT \"IDTank\" as \"att1\", \"TankName\" as \"att2\"\n" +
        "FROM \"Tbl_TankNew\"\n" +
        "WHERE \"IDProductionUnit\" = '$idNhaSX' \n" +
        "ORDER BY \"TankName\"";
    return query;
  }
  static String queryGetDetailTank(String idTank){
    String query = "2"+"^"+"SELECT * FROM get_type_tank('$idTank')";
    return query;
  }
}