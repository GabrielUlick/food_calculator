
import 'package:flutter/material.dart';
import '../models/food_product.dart';
import '../database/database_helper.dart';

class FoodProductProvider with ChangeNotifier {
  List<FoodProduct> _products = [];
  List<FoodProduct> _searchResults = [];
  bool _isLoading = false;

  List<FoodProduct> get products => _products;
  List<FoodProduct> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  // Carrega todos os produtos
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await DatabaseHelper.instance.getAllFoodProducts();
      _searchResults = _products;
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Busca produtos por nome ou marca
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = _products;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await DatabaseHelper.instance.searchFoodProducts(query);
    } catch (e) {
      print('Erro ao buscar produtos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona um novo produto
  Future<void> addProduct(FoodProduct product) async {
    try {
      await DatabaseHelper.instance.createFoodProduct(product);
      _products.add(product);
      _searchResults = _products;
      notifyListeners();
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      rethrow;
    }
  }

  // Atualiza um produto existente
  Future<void> updateProduct(FoodProduct product) async {
    try {
      await DatabaseHelper.instance.updateFoodProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _searchResults = _products;
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      rethrow;
    }
  }

  // Remove um produto
  Future<void> deleteProduct(String id) async {
    try {
      await DatabaseHelper.instance.deleteFoodProduct(id);
      _products.removeWhere((p) => p.id == id);
      _searchResults = _products;
      notifyListeners();
    } catch (e) {
      print('Erro ao remover produto: $e');
      rethrow;
    }
  }

  // Obtém um produto por ID
  Future<FoodProduct?> getProductById(String id) async {
    try {
      return await DatabaseHelper.instance.getFoodProductById(id);
    } catch (e) {
      print('Erro ao buscar produto: $e');
      return null;
    }
  }
}
