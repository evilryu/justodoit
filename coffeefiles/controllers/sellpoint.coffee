'use strict'

define ['can', 'components/sellpointComponents'], (can) ->

	SellPoint = can.Control.extend

		init : (element, options) ->

			@options.searchProducts  = new can.List([])
			@options.orderProducts = new can.List([])
			@element.html can.view('views/sellpoint/sellpoint-layout.mustache', {
					products : @options.searchProducts
					orderProducts: @options.orderProducts
				})

		'.search-inventory keyup' : (el) ->
			self = @
			clearTimeout self.options.searchTimer
			self.options.searchTimer = setTimeout ->
				self.getProductsByFilter(el.val())
			,1200

		'.sellpoint updateOrderDetail' : (el, ev, product) ->
			if @productAlreadyInOrder(product) is false 
				@insertProductInOrder(product)
			@updateProductQuantityTable(product)

		'.sellpoint increaseTableQuantity' : (el, ev, product) ->
			for prod in @options.searchProducts
				if prod.CODE is product.CODE
					prod.attr('QUANTITY', prod.QUANTITY + 1)
					break

		'.sellpoint decreaseTableQuantity' : (el, ev, product) ->
			for prod in @options.searchProducts
				if prod.CODE is product.CODE
					prod.attr('QUANTITY', prod.QUANTITY - 1)
					break

		productAlreadyInOrder : (product) ->
			for prod in @options.orderProducts
				if prod.CODE is product.CODE
					@updateProductQuantityPrice(prod)
					return true
			return false

		updateProductQuantityPrice : (product) ->
			can.batch.start()
			product.attr('QUANTITY', product.attr('QUANTITY') + 1)
			product.attr('TOTAL', product.QUANTITY * product.PRICE)
			can.batch.stop()

		insertProductInOrder : (product) ->
			can.batch.start()
			@options.orderProducts.push({
					CODE: product.CODE
					NAME: product.NAME
					QUANTITY: 1
					PRICE: product.PRICE
					TOTAL: product.PRICE
				})
			can.batch.stop()

		updateProductQuantityTable : (product) ->
			if product.attr('QUANTITY') > 0
				product.attr('QUANTITY', product.QUANTITY - 1)

		getProductsByFilter : (query) ->
			#TODO: make request to database and match either code or name of product.
			dummyData = [{
					CODE : 'CU1'
					NAME : 'Cuaderno 3 Materias Copan'
					QUANTITY: 25
					PRICE: 35
					PROVIDER: 'Copan'
				}, {
					CODE : 'LP2'
					NAME : 'Lapiz tinta negro BIC'
					QUANTITY: 15
					PRICE: 12
					PROVIDER: 'BIC'
				},{
					CODE : 'CU2'
					NAME : 'Cuaderno 2 Materias Copan'
					QUANTITY: 2
					PRICE: 20
					PROVIDER: 'Copan'
				},{
					CODE : 'BORR1'
					NAME : 'Borrador'
					QUANTITY: 5
					PRICE: 10
					PROVIDER: 'Borradores'
				},{
					CODE : 'MOCH1'
					NAME : 'Mochila'
					QUANTITY: 20
					PRICE: 550
					PROVIDER: 'Jansport'
				}]

			@options.searchProducts.replace(dummyData)

		destroy : ->
			can.Control.prototype.destroy.call @