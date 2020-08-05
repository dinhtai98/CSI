class ThongKe{

  static String queryThongKe = '18^SELECT (SELECT COUNT(*) FROM "Tbl_ManagementAuthority") AS "att1", (SELECT COUNT(*) FROM "Tbl_ManagementAuthority" WHERE "Type" = 1) AS "att2", (SELECT COUNT(*) FROM "Tbl_ManagementAuthority" WHERE "Type" = 2) AS "att3", (SELECT COUNT(*) FROM "Tbl_ManagementAuthority" WHERE "Type" = 3) AS "att4", (SELECT COUNT(*) FROM "Tbl_ManagementAuthority" WHERE "Type" = 4) AS "att5", (SELECT COUNT(*) FROM "Tbl_HatcheryNew") AS "att6", (SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 1 AND "TypeOfBusiness" = 1) AS "att7", (SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 1 AND "TypeOfBusiness" = 2) AS "att8", (SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 1 AND "TypeOfBusiness" = 3 ) AS "att9", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 2 AND "TypeOfBusiness" = 1 ) AS "att10", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 2 AND "TypeOfBusiness" = 2 ) AS "att11", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 3 AND "TypeOfBusiness" = 3 ) AS "att12", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 3 AND "TypeOfBusiness" = 1 ) AS "att13", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 3 AND "TypeOfBusiness" = 2 ) AS "att14", ( SELECT COUNT(*) FROM "Tbl_HatcheryNew" WHERE "TypeOfHatchery" = 3 AND "TypeOfBusiness" = 3 ) AS "att15", (SELECT COUNT(*) FROM "Tbl_Agency") AS "att16", ( SELECT COUNT(*) FROM "Tbl_PostlarveaBuyer") AS "att17", (SELECT COUNT(*) FROM "Tbl_User" WHERE "TypeAuthority" = 4) AS "att18"';
  /*
  static String queryThongKe = "25 ^ SELECT  (\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_ManagementAuthority\"\n" +
      "        ) AS att1,\n" +
      "\t\t(\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_ManagementAuthority\"\n" +
      "\t\tWHERE \"Type\" = 1\n" +
      "        ) AS att2,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_ManagementAuthority\"\n" +
      "\t\tWHERE \"Type\" = 2\n" +
      "        ) AS att3,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_ManagementAuthority\"\n" +
      "\t\tWHERE \"Type\" = 3\n" +
      "        ) AS att4,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_ManagementAuthority\"\n" +
      "\t\tWHERE \"Type\" = 4\n" +
      "        ) AS att5,\n" +
      "        (\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "        ) AS att6, \n" +
      "\t\t(\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 1 AND \"TypeOfBusiness\" = 1\n" +
      "        ) AS att7,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 1 AND \"TypeOfBusiness\" = 2\n" +
      "        ) AS att8,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 1 AND \"TypeOfBusiness\" = 3\n" +
      "        ) AS att9,\n" +
      "\t\t(\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 2 AND \"TypeOfBusiness\" = 1\n" +
      "        ) AS att10,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 2 AND \"TypeOfBusiness\" = 2\n" +
      "        ) AS att11,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 3 AND \"TypeOfBusiness\" = 3\n" +
      "        ) AS att12,\n" +
      "\t\t(\n" +
      "        SELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 3 AND \"TypeOfBusiness\" = 1\n" +
      "        ) AS att13,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 3 AND \"TypeOfBusiness\" = 2\n" +
      "        ) AS att14,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_HatcheryNew\"\n" +
      "\t\tWHERE \"TypeOfHatchery\" = 3 AND \"TypeOfBusiness\" = 3\n" +
      "        ) AS att15,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_Agency\"\n" +
      "\t\t) AS att16,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_PostlarveaBuyer\"\n" +
      "\t\t) AS att17,\n" +
      "\t\t(\n" +
      "\t\tSELECT COUNT(*)\n" +
      "        FROM   \"Tbl_User\"\n" +
      "\t\tWHERE \"TypeAuthority\" = 4\n" +
      "\t\t) AS att18";

   */
}