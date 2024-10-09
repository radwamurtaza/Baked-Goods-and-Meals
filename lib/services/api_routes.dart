class APIRoutes {
  // static const String baseURL = 'http://192.168.0.179:8000/';
  static const String baseURL = 'https://expertinmarketing.com/bgam/';
  static const String signup = baseURL + 'auth/signup.php';
  static const String login = baseURL + 'auth/login.php';
  static const String forgotPassword = baseURL + 'auth/forgot_password.php';
  static const String resetPassword = baseURL + 'auth/reset_password.php';
  static const String vendorLogin = baseURL + 'auth/vendor_login.php';
  static const String addProduct = baseURL + 'vendor/add_product.php';
  static const String addPlan = baseURL + 'vendor/add_plan.php';
  static const String getVendorOrders = baseURL + 'vendor/view_all_orders.php';
  static const String getAllOrders = baseURL + 'admin/view_all_orders.php';
  static const String deliverOrder = baseURL + 'vendor/deliver_order.php';
  static const String cancelOrder = baseURL + 'vendor/cancel_order.php';
  static const String getCounts = baseURL + 'vendor/get_counts.php';
  static const String getAllCounts = baseURL + 'admin/get_all_counts.php';
  static const String updateProfile = baseURL + 'customer/update_profile.php';
  static const String rateVendor = baseURL + 'customer/rate_vendor.php';
  static const String uploadFile = baseURL + 'customer/upload_file.php';
  static const String createPost = baseURL + 'customer/create_post.php';
  static const String getAllPosts = baseURL + 'customer/get_all_posts.php';
  static const String likePost = baseURL + 'customer/add_like.php';
  static const String unlikePost = baseURL + 'customer/remove_like.php';
  static const String createAttachment =
      baseURL + 'customer/create_attachment.php';
  static const String updateVendor = baseURL + 'customer/update_vendor.php';
  static const String createVendor = baseURL + 'admin/create_vendor.php';
  static const String registerVendor = baseURL + 'admin/register_vendor.php';
  static const String banVendor = baseURL + 'admin/ban_vendor.php';
  static const String banUser = baseURL + 'admin/ban_user.php';
  static const String unbanVendor = baseURL + 'admin/unban_vendor.php';
  static const String unbanUser = baseURL + 'admin/unban_user.php';
  static const String getVendors = baseURL + 'customer/view_all_vendors.php';
  static const String getAllVendors = baseURL + 'admin/view_all_vendors.php';
  static const String getAllUsers = baseURL + 'admin/view_all_users.php';
  static const String searchVendors = baseURL + 'customer/search_vendor.php';
  static const String getVendor = baseURL + 'customer/get_single_vendor.php';
  static const String getUser = baseURL + 'customer/get_single_profile.php';
  static const String placeOrder = baseURL + 'customer/place_order.php';
  static const String getOrderHistory =
      baseURL + 'customer/get_order_history.php';
  static const String getVendorProducts =
      baseURL + 'vendor/get_all_product_types.php';

  static const String mailjetSecret = "bd90688653259594de879872c353053e";
  static const String mailjetAPI = "bc809c949b5432f4916ac949d2fdcd1d";
}
