import 'package:flutter_helloworld/utils/diacritics.dart';

class Producer{

  static String query_GetAllProducers =  "7^select \"IDBroodstockProducer\" as \"att1\", \"BroodstockProducerName\" as \"att2\","
      " \"BroodstockProducerTypes\" as \"att3\",\n" +
      "\"BroodstockProducerSpecies\" as \"att4\", \"RankingHatchery\" as \"att5\", \"RankingDFISH\" as \"att6\",\n"
      "\"BroodstockProducerCountry\" as \"att7\" \n" +
      "from public.\"Tbl_BroodstockProducer\" order by \"BroodstockProducerName\"";
  static String queryFilterNameProducer(String filter){
    if(filter.length > 0){
      filter = "ILIKE '%${TextUnaccented.removeDiacritics(filter)}%'";
    }else{
      filter = 'IS NOT NULL';
    }
    String query =  "7^select \"IDBroodstockProducer\" as \"att1\", \"BroodstockProducerName\" as \"att2\","
        " \"BroodstockProducerTypes\" as \"att3\",\n" +
        "\"BroodstockProducerSpecies\" as \"att4\", \"RankingHatchery\" as \"att5\", \"RankingDFISH\" as \"att6\",\n"
        "\"BroodstockProducerCountry\" as \"att7\" \n" +
        "from public.\"Tbl_BroodstockProducer\" \n"
        "where (\"BroodstockProducerName\") $filter "
        "order by \"BroodstockProducerName\"";
    return query;
  }
  static String queryGetProducer(String idPro){
    String query = "21^SELECT \"IDBroodstockProducer\" as \"att1\", \"BroodstockProducerName\" as \"att2\", \"ContactProducerLastName\" as \"att3\", \n" +
        "\"ContactProducerFirstName\" as \"att4\", \"ContactProducerPhone\" as \"att5\", \"BroodstockProducerSpecies\" as \"att6\", \n" +
        "\"BroodstockProducerTypes\" as \"att7\", \"BroodstockProducerEstablishmentYear\" as \"att8\", \n" +
        "\"BroodstockProducerBusinessNumber\" as \"att9\", \"BroodstockProducerCountry\" as \"att10\",\n" +
        "\"BroodstockProducerStreetAddress\" as \"att11\",\"BroodstockProducerCity\" as \"att12\", \n" +
        "\"BroodstockProducerState\" as \"att13\", \"BroodstockProducerPostalCode\" as \"att14\", \n" +
        "\"MarketShareCurrentYear\" as \"att15\", \"MarketShareLast3Years\" as \"att16\", \n" +
        "\"BroodstockProducerEmail\" as \"att17\", \"ProducerCompanyCode\" as \"att18\", \n" +
        "\"FirstYearVietNam\" as \"att19\", \"RankingHatchery\" as \"att20\", \"RankingDFISH\" as \"att21\" \n" +
        "FROM \"Tbl_BroodstockProducer\" WHERE \"IDBroodstockProducer\" = '$idPro'";
    return query;
  }
}