(function() {
  'use strict';
  require(['can', 'helpers/helpers', 'controllers/header', 'controllers/product', 'controllers/provider', 'controllers/inventory', 'controllers/saleorder', 'controllers/isv', 'controllers/salesdetails', 'components/loginComponent', 'models/loginModels'], function(can, Helpers, Header, Product, Provider, Inventory, SaleOrder, ISV, SalesDetails) {
    var Router;
    Router = can.Control.extend({
      init: function(element, options) {
        this.options.userMap = new can.Map({
          user: ''
        });
        can.route.bind('change', function(ev, attr, how, newVal, oldVal) {
          if (newVal !== 'login') {
            return self.checkUserAuthentication();
          }
        });
        return new Header(can.$('.top-menu'), {
          user: this.options.userMap
        });
      },
      checkUserAuthentication: function() {
        var deferred, self;
        self = this;
        deferred = LoginModel.findOne();
        return deferred.then(function(response) {
          if (response.success === false) {
            return can.route.attr('route', 'login');
          } else {
            return self.options.userMap.attr('user', response.name);
          }
        }, function(xhr) {
          return Helpers.showMessage('error', 'Error desconocido, favor intentar de nuevo ');
        });
      },
      'route': function(data) {
        can.route.attr('route', 'login');
        return {
          'login route': function(data) {
            var component;
            component = can.mustache('<login-form></login-form>');
            return can.$('.main-container').html(component());
          }
        };
      },
      'crearProducto route': function(data) {
        this.destroyControllers();
        return new Product(can.$('.main-container'), {
          edit: false
        });
      },
      'editarProducto route': function(data) {
        this.destroyControllers();
        return new Product(can.$('.main-container'), {
          edit: true
        });
      },
      'editarProducto/:productoid route': function(data) {
        this.destroyControllers();
        return new Product(can.$('.main-container'), {
          edit: true
        });
      },
      'crearProveedor route': function(data) {
        this.destroyControllers();
        return new Provider(can.$('.main-container'), {
          edit: false
        });
      },
      'editarProveedor route': function(data) {
        this.destroyControllers();
        return new Provider(can.$('.main-container'), {
          edit: true
        });
      },
      'editarProveedor/:proveedorid route': function(data) {
        this.destroyControllers();
        return new Provider(can.$('.main-container'), {
          edit: true
        });
      },
      'inventario route': function(data) {
        this.destroyControllers();
        return new Inventory(can.$('.main-container'));
      },
      'venta route': function(data) {
        this.destroyControllers();
        return new SaleOrder(can.$('.main-container'));
      },
      'editarISV route': function(data) {
        this.destroyControllers();
        return new ISV(can.$('.main-container'));
      },
      'detallesVenta route': function(data) {
        this.destroyControllers();
        return new SalesDetails(can.$('.main-container'));
      },
      'destroyControllers': function() {
        var controller, currentControllers, _i, _len, _results;
        currentControllers = can.$('.main-container').data().controls;
        if (currentControllers !== void 0) {
          _results = [];
          for (_i = 0, _len = currentControllers.length; _i < _len; _i++) {
            controller = currentControllers[_i];
            _results.push(this.destroyController(controller));
          }
          return _results;
        }
      },
      'destroyController': function(controller) {
        if (controller !== void 0 && controller !== null) {
          return controller.destroy();
        }
      }
    });
    return $(document).ready(function() {
      new Router($('body'));
      return can.route.ready();
    });
  });

}).call(this);
