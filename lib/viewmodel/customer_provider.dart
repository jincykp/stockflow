import 'package:flutter/material.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/repositories/customer_repositories.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository = CustomerRepository();

  // List to store all customers
  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  // Selected customer for viewing/editing
  CustomerModel? _selectedCustomer;
  CustomerModel? get selectedCustomer => _selectedCustomer;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Initialize and fetch customers for a user
  Future<void> fetchCustomers(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      final customersList = await _repository.getCustomers(userId);
      _customers = customersList;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch customers: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Add a new customer
  Future<bool> addCustomer(CustomerModel customer) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      await _repository.addCustomer(customer);
      _customers.insert(0, customer); // Add to the beginning of the list

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add customer: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing customer
  Future<bool> updateCustomer(CustomerModel updatedCustomer) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      await _repository.updateCustomer(updatedCustomer);

      // Update in local list
      final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      // Update selected customer if it's the same one
      if (_selectedCustomer != null &&
          _selectedCustomer!.id == updatedCustomer.id) {
        _selectedCustomer = updatedCustomer;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      await _repository.deleteCustomer(customerId);

      // Remove from local list
      _customers.removeWhere((c) => c.id == customerId);

      // Clear selected customer if it's the deleted one
      if (_selectedCustomer != null && _selectedCustomer!.id == customerId) {
        _selectedCustomer = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set selected customer
  void selectCustomer(CustomerModel customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Clear selected customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper method to clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Fixed getCustomerById method to properly handle null
  Future<bool> getCustomerById(String customerId) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      // First check if we already have it in our list
      final existingCustomerIndex =
          _customers.indexWhere((c) => c.id == customerId);

      if (existingCustomerIndex != -1) {
        _selectedCustomer = _customers[existingCustomerIndex];
        notifyListeners();
        return true;
      }

      // If not found in our list, fetch from repository
      final customer = await _repository.getCustomer(customerId);

      if (customer != null) {
        _selectedCustomer = customer;

        // Also add it to our list if it's not already there
        if (!_customers.any((c) => c.id == customer.id)) {
          _customers.add(customer);
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Customer not found';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to get customer: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
