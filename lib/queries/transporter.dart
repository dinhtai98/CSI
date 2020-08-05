class Transport{
  static  String query_getAllTransporter = "2" + "^" +"SELECT \"IDTransporter\" as \"att1\", \"TransporterName\" as \"att2\"\n" +
      "FROM \"Tbl_Transporter\"";
 static String queryInsertTransportInfomation(String idCon, String idTrans, String name, String phone,
      String departTime, String arrivalTime, String idStaff) {
    String query = "SELECT public.procinserttbl_contracttransporter('$idCon', '$idTrans', '$name', '$phone', '$departTime', '$arrivalTime', '$idStaff')";
    return query;
  }
  static String queryGetTransportOfContract(String idCon){
    String query = "6"+"^"+"SELECT \"Tbl_Transporter\".\"TransporterName\" as \"att1\",\n" +
        " \"Tbl_ContractTransport\".\"TransporterName\" as \"att2\",\n" +
        " \"Tbl_ContractTransport\".\"TransporterPhone\" as \"att3\",\n" +
        " \"DepartTime\" as \"att4\", \"ArrivalTimedHatchery\" as \"att5\",\n" +
        " \"Tbl_User\".\"FullName\" as \"att6\"\n" +
        "FROM \"Tbl_ContractTransport\", \"Tbl_Transporter\", \"Tbl_User\"\n" +
        "WHERE \"Tbl_ContractTransport\".\"IDTransporter\" = \"Tbl_Transporter\".\"IDTransporter\" AND\n" +
        "\"Tbl_User\". \"IDUser\" = \"Tbl_ContractTransport\".\"IDStaff\" AND\n" +
        "\"Tbl_ContractTransport\".\"IDContract\" = '$idCon'";
    return query;
  }
}