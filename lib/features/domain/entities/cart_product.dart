class CartProduct {
  final int id;
  final String name;
  final String code;
  double? cost;
  double labelPrice;
  int stockQty;
  double unitPrice;
  int quantity;

  CartProduct({
    required this.id,
    required this.name,
    required this.code,
    required this.unitPrice,
    required this.quantity,
    this.cost = 0,
    required this.stockQty,
    required this.labelPrice,
  });
}
