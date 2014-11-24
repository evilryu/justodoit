'use strict'

require ['bootstrap', 'can', 'controllers/header',
'controllers/product'], (bootstrap, can, Header, Product) ->

    Router = can.Control.extend

        init : (element, options) ->
            new Header(can.$('.top-menu'))
        'route' : (data) ->
            window.location.hash = '#!crearProducto'
        
        'crearProducto route' : (data) ->
            @destroyControllers
            new Product(can.$('.main-container'), edit:false)
        'editarProducto route' : (data) ->
            @destroyControllers
            console.log('dafuq')
            new Product(can.$('.main-container'), edit:true)
        'editarProducto/:productoid route' : (data) ->
            @destroyControllers
            new Product(can.$('.main-container'), edit:true)
        'destroyControllers' : ->
            currentControllers = can.$('.main-container').data().controls
            @destroyController controller for controller in currentControllers

        'destroyController' : (controller) ->
            if controller? then controller.destroy()

    $(document).ready ->
        new Router($('body'))
        can.route.ready()