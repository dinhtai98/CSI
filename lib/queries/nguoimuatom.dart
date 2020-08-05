class NguoiMuaTom{
  static String queryDangKyNguoiMuaTom(String name, String idNumber, String phone, String email, String address, int intention, int type) {
    String query = "1^select procinserttbl_postlarveabuyer('$name', '$idNumber', '$phone', '$email','$address', '$intention','$type') as \"att1\" ";
    return query;
  }
}