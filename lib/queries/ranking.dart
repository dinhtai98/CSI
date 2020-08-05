class Ranking{
  static String queryGetHatcheryRankingImportContract(String idCon){
    String s = "3^SELECT \"Ranking\" as \"att1\", \"Comment\" as \"att2\", \"RankingDate\" as \"att3\"\n" +
        "FROM \"Tbl_BroodstockImportContract\" LEFT JOIN \n" +
        "\"Tbl_BroodStockProducerHatcheryRanking\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" =\n" +
        "\"Tbl_BroodStockProducerHatcheryRanking\".\"IDBroodStockImportContract\"\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idCon'";
    return s;
  }
  static String queryGetDFISHRankingImportContract(String idCon){
    String s = "3^SELECT \"Ranking\" as \"att1\", \"Comment\" as \"att2\", \"RankingDate\" as \"att3\"\n" +
        "FROM \"Tbl_BroodstockImportContract\" LEFT JOIN \n" +
        "\"Tbl_BroodStockProducerDFISHRanking\" ON\n" +
        "\"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" =\n" +
        "\"Tbl_BroodStockProducerDFISHRanking\".\"IDBroodStockImportContract\"\n" +
        "WHERE \"Tbl_BroodstockImportContract\".\"IDBroodstockContract\" = '$idCon'";
    return s;
  }
  static String queryGetRankingBroodstockContract(String idCon){
    String s = "3^SELECT \"Ranking\" as \"att1\", \"Comment\" as \"att2\", \"RankingDate\" as \"att3\"\n" +
        "FROM \"Tbl_BroodstockAssignContract\" LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        "\"Tbl_BroodstockAssignContract\".\"IDBroodstockAssignContract\" =\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"IDBroodstockAssignContract\" = '$idCon'";
    return s;
  }
  static String queryGetRankingNaupliiContract(String idCon){
    String s = "3^SELECT \"Ranking\" as \"att1\", \"Comment\" as \"att2\", \"RankingDate\" as \"att3\"\n" +
        "FROM \"Tbl_NaupliiContract\" LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        "\"Tbl_NaupliiContract\".\"IDNaupliiContract\" =\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"IDNaupliiContract\" = '$idCon'";
    return s;
  }
  static String queryGetRankingPostlarveaContract(String idCon){
    String s = "3^SELECT \"Ranking\" as \"att1\", \"Comment\" as \"att2\", \"RankingDate\" as \"att3\"\n" +
        "FROM \"Tbl_PostlarveaContract\" LEFT JOIN \"Tbl_HatcheryBUYERRanking\" ON\n" +
        "\"Tbl_PostlarveaContract\".\"IDPostlarveaContract\" =\n" +
        "\"Tbl_HatcheryBUYERRanking\".\"IDContract\"\n" +
        "WHERE \"IDPostlarveaContract\" = '$idCon'";
    return s;
  }
}