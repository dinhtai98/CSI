package queries;

public class ABC {
    String s = "SELECT \"IDHatchery\" as \"att1\", \"HatcheryName\" as \"att2\", \"OwnerName\" as \"att3\",\n" +
            "\"Tbl_HatcheryNew\".\"Address\" as \"att4\", \"Tbl_HatcheryNew\".\"Phone\" as \"att5\",\n" +
            "\"Photo\" as \"att6\", \"IDUser\" as \"att7\",\"EstablishmentYear\" as \"att8\",\n" +
            "\"BussinessNumber\" as \"att9\", \"Tbl_Province\".\"ProvinceName\" as \"att10\",\n" +
            "\"NumberOfCluster\" as \"att11\", \"SpeciesProducing\" as \"att12\",\n" +
            "\"TypeOfBusiness\" as \"att13\"\n" +
            "FROM \"Tbl_User\", \"Tbl_HatcheryNew\", \"Tbl_Province\" \n" +
            "WHERE \"WorkPlace\" = \"Tbl_HatcheryNew\".\"IDHatchery\" AND\n" +
            "\"Tbl_HatcheryNew\".\"IDProvince\" = \"Tbl_Province\".\"IDProvince\" AND\n" +
            "\"WorkPlace\" = 'HATCH1'";
}
