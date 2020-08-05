import 'package:flutter_helloworld/utils/diacritics.dart';

class Hatchery {
   static String queryGetAllStaffHatchery =  "14^select \"IDHatcheryStaff\" as \"att1\", \"HatcheryStaffLastName\" as \"att2\", \"HatcheryStaffFirstName\" as \"att3\",\n" +
       "\"HatcheryStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"HatcheryStaffEmail\" as \"att6\",\n" +
       "\"Tbl_HatcheryStaff\".\"IDHatchery\" as \"att7\",\n" +
       "\"Username\" as \"att8\", \"Password\" as \"att9\", \"Active\" as \"att10\", \"CreatedDate\" as \"att11\",\n" +
       "\"HatcheryStaffPhoto\" as \"att12\",\"HatcheryStaffStartedWorkingDate\" as \"att13\",\n" +
       "\"Tbl_Hatchery\".\"HatcheryName\" as \"att14\"\n" +
       "from public.\"Tbl_HatcheryStaff\",\"Tbl_Hatchery\"\n" +
       "WHERE \"Tbl_HatcheryStaff\".\"IDHatchery\" = \"Tbl_Hatchery\".\"IDHatchery\"";
   static String queryHatcherySaveEvidence(String IDCon, String IDStaff, String Photo){
      String query = "select procInsertTbl_CustomClearance_CurrentProcess ('$IDCon', '$IDStaff', '$Photo')";
      return query;
   }
   static String queryGetAllHatcheryExceptMe(String idHat, String term){
     if(term.length > 0){
       term = "ILIKE '%${TextUnaccented.removeDiacritics(term)}%'";
     }else{
       term = 'IS NOT NULL';
     }
     String query = "2" + "^" + "Select \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\" \n" +
         "from \"Tbl_HatcheryNew\" WHERE \"IDHatchery\" <> '$idHat' AND                                                                 (\"HatcheryName\") $term \n" +
         "ORDER BY \"HatcheryName\" ";
     return query;
   }
   static String queryGetStaffHatchery(String idStaff){
     String query = "14" + "^" + "select \"IDHatcheryStaff\" as \"att1\", \"HatcheryStaffLastName\" as \"att2\", \"HatcheryStaffFirstName\" as \"att3\",\n" +
         "\"HatcheryStaffPhone\" as \"att4\", \"Manage\" as \"att5\", \"HatcheryStaffEmail\" as \"att6\",\"Tbl_Hatchery\".\"HatcheryName\" as \"att7\",\n" +
         "\"Username\" as \"att8\", \"Password\" as \"att9\", \"Active\" as \"att10\", \"CreatedDate\" as \"att11\",\n" +
         "\"HatcheryStaffPhoto\" as \"att12\",\"HatcheryStaffStartedWorkingDate\" as \"att13\", \n" +
         "\"Ranking\" as \"att14\"\n" +
         "from public.\"Tbl_HatcheryStaff\", \"Tbl_Hatchery\" \n" +
         "WHERE \"Tbl_HatcheryStaff\".\"IDHatchery\" = \"Tbl_Hatchery\".\"IDHatchery\" AND\n" +
         "\"IDHatcheryStaff\" = '$idStaff'";
     return query;
   }

   static String queryGetAllHatcheryByID(String term, String province){
     print(province);
     if(term.length > 0){
       term = "ILIKE '%${TextUnaccented.removeDiacritics(term)}%'";
     }else{
       term = 'IS NOT NULL';
     }
     String query = "3" + "^" + "SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \"Photo\" as \"att3\"\n" +
         "FROM \"Tbl_HatcheryNew\"\n" +
         "WHERE (\"HatcheryName\") $term AND \"IDProvince\" = '$province' \n"+
         "ORDER BY \"HatcheryName\" ";
     return query;
   }

   /* Dung bang hatchery new
   static String queryGetAllHatcheryByID(String id, String term){
     if(term.length > 0){
       term = "ILIKE '%${TextUnaccented.removeDiacritics(term)}%'";
     }else{
       term = 'IS NOT NULL';
     }

     String query = "3" + "^" + "SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \"Photo\" as \"att3\"\n" +
         "FROM \"Tbl_HatcheryNew\"\n" +
         "WHERE (\"HatcheryName\") $term \n"+
         "ORDER BY \"HatcheryName\"";
     return query;
   }
    */

   /* Goc - dung bang hatchery
   static String queryGetAllHatcheryByID(String id, String term){
     String dard,dah;
     if(id.contains('DAH')) {
       dah = "= '$id'";
       dard = 'IS NOT NULL';
     }else if(id.contains('DAR')) {
       dard = "= '$id'";
       dah = 'IS NOT NULL';
     }else if(id.contains('TRADE')) {
       dard = "IS NOT NULL";
       dah = 'IS NOT NULL';
     }
     if(term.length > 0){
       term = "ILIKE '%${TextUnaccented.removeDiacritics(term)}%'";
     }else{
       term = 'IS NOT NULL';
     }
     String query = "3" + "^" + "SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \"Photo\" as \"att3\"\n" +
         "FROM \"Tbl_HatcheryNew\"\n" +
         "WHERE \"Tbl_HatcheryNew\".\"IDDAH\" $dah AND \"Tbl_Hatchery\".\"IDDARD\" $dard AND\n"+
         "(\"HatcheryName\") $term \n"+
         "ORDER BY \"HatcheryName\"";
     return query;
   }
    */

   static String queryGetHatchery(String idHatchery){
     String query = "13 ^ SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \"OwnerName\" as \"att3\",\n" +
         "\"Tbl_HatcheryNew\".\"Address\" as \"att4\", \"Tbl_User\".\"Phone\" as \"att5\",\n" +
         "\"Tbl_HatcheryNew\".\"Photo\" as \"att6\", \"IDUser\" as \"att7\", \"EstablishmentYear\" as \"att8\",\n" +
         "\"BusinessNumber\" as \"att9\", \"Tbl_Province\".\"ProvinceName\" as \"att10\",\n" +
         "\"NumberOfCluster\" as \"att11\", \"SpeciesProducing\" as \"att12\",\n" +
         "\"TypeOfBusiness\" as \"att13\"\n" +
         "FROM \"Tbl_User\", \"Tbl_HatcheryNew\", \"Tbl_Province\" \n" +
         "WHERE \"WorkPlace\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
         "\"Tbl_HatcheryNew\".\"IDProvince\" = \"Tbl_Province\".\"IDProvince\" AND\n" +
         "\"WorkPlace\" = '$idHatchery'";
     return query;
   }
   static String queryWorkingHistory(String idStaff){
     String query = "5" + "^" + "select \"Tbl_Hatchery\".\"HatcheryName\" as \"att1\", \"StartDate\" as \"att2\", \"EndDate\" as \"att3\",\n" +
         "\"Comment\" as \"att4\", \"Ranking\" as \"att5\"\n" +
         "from \"Tbl_StaffWorkingHistory\", \"Tbl_Hatchery\"\n" +
         "where \"Tbl_StaffWorkingHistory\".\"IDHatchery\" = \"Tbl_Hatchery\".\"IDHatchery\" AND \"IDStaff\" = '$idStaff'\n" +
         "order by \"StartDate\" desc";
     return query;
   }
   static String queryDangKyCoSoSanXuat(String companyName, String owner, String website, String businessNumber, String address,
        String startYear, String photo, int typeOfBusiness, int typeOfHatchery, String speciesProducing, int numberProCluster){
     String query = "1^select * from proc_dangkycososanxuat ('$companyName', '$owner', '$website','$businessNumber', '$address', '$startYear',"
         "          '$photo', '$typeOfBusiness', '$typeOfHatchery','$speciesProducing', '$numberProCluster')";
     return query;
   }
   static String queryGetCoSoSanXuatTheoLoai(int typeBusiness){
     String query = "4 ^ SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \n" +
         "\"TypeOfBusiness\" as \"att3\", \"Photo\" as \"att4\"\n" +
         "FROM \"Tbl_HatcheryNew\"\n" +
         "WHERE \"TypeOfHatchery\" = '$typeBusiness'";
     return query;
   }
   static String queryGetAllCoSoSanXuat = "25^SELECT \"HatcheryName\" as \"att1\", \"OwnerName\" as \"att2\", \"Tbl_HatcheryNew\".\"Phone\" as \"att3\",\n" +
       "\"Tbl_HatcheryNew\".\"Address\" as \"att4\", \"Photo\" as \"att5\", \n" +
       "\"EstablishmentYear\" as \"att6\", \"BussinessNumber\" as \"att7\", \n" +
       "\"NumberOfCluster\" as \"att8\", \"SpeciesProducing\" as \"att9\",\n" +
       "\"TypeOfBusiness\" as \"att10\", \"TypeOfHatchery\" as \"att11\",\n" +
       "\"Username\" as \"att18\", \"Password\" as \"att19\",\n" +
       "\"IDNumber\" as \"att20\", \"TypeAuthority\" as \"att21\"\n" +
       "FROM \"Tbl_User\", \"Tbl_HatcheryNew\"\n" +
       "WHERE \"Tbl_User\".\"WorkPlace\" = \"Tbl_HatcheryNew\".\"IDHatchery\"";
}