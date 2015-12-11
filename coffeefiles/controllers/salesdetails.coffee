'use strict'

define ['can', 'models/salesdetailsModels'], (can, SalesDetailModel) ->

	SalesDetails = can.Control.extend

		init : (element, options) ->
			@initSalesDetailsOptions()
			@renderTemplate()

		'.search-order-details click' : (el) ->
			@getSalesDetailsByDateRange()

		'.search-sales-details keyup' : (el) ->
			query = el.val().trim()
			self = @
			clearTimeout self.options.searchTimer
			self.options.searchTimer = setTimeout ->
				if query isnt '' and /\S+/.test(query) is true
					self.filterProducts(query)
				else
					self.showAllProducts()
			,1200

		'li.inventory-page click' : (ev) ->
			if can.$(ev.context).hasClass('active')
				return
			else
				index = can.$('li.inventory-page').index ev.context
				can.$('li.inventory-page').removeClass 'active'
				can.$(ev.context).addClass 'active'
				startIndex = index * 2
				lastIndex = startIndex + 2
				@options.dataRender.replace @options.candidates.slice(startIndex, lastIndex)

		calculatePages : (data) -> 
			@options.amountPages = Math.ceil data.length / 2
			temp = new can.List []
			temp.push(i) for i in [1..@options.amountPages]
			@options.pages.replace temp

		renderTemplate : ->
			@element.html can.view('views/salesdetails/salesdetails.mustache',
				products : @options.dataRender
				startDate : @options.startDate
				endDate: @options.endDate
				pages: @options.pages
			,
				formatDate : (date) ->
					moment(date()).format 'DD-MM-YYYY' 
			)

		renderTable : (products) ->
			can.$('.sales-details-table').html can.view('views/salesdetails/salesdetails-table.mustache',
					products : products
				,
					formatDate : (date) ->
						moment(date()).format 'DD-MM-YYYY'
				)

			can.$('.pagination-container').html can.view('views/inventory/pagination.mustache',
				pages : @options.pages)

			can.$('li.inventory-page:first').addClass 'active'

		initSalesDetailsOptions : ->
			@options.products = new can.List []
			@options.dataRender = new can.List []
			@options.pages = new can.List []
			@options.candidates = new can.List []
			@options.startDate = can.compute ''
			@options.endDate = can.compute ''
			@options.amountPages = 0

		showAllProducts : ->
			@calculatePages @options.products
			@options.candidates.replace @options.products
			@options.dataRender.replace @options.products.slice(0,2)
			@renderTable @options.dataRender
		

		filterProducts : (query) ->
			matches = new can.List []
			matchRegexp = new RegExp(query, 'i')
			
			for product in @options.products
				for item in product.items
					if matchRegexp.test(item.name) is true
						matches.push product
						break

			@options.candidates.replace matches
			@calculatePages @options.candidates
			@options.dataRender.replace @options.candidates.slice(0,2)
			@renderTable @options.dataRender

		getSalesDetailsByDateRange : ->
			self = @
			deferred = SalesDetailModel.findAll
				startDate: self.options.startDate()
				endDate : self.options.endDate()

			deferred.then (response) ->
				if response.success is true
					self.options.products.replace response
					self.options.candidates.replace response
					self.calculatePages self.options.products
					self.options.dataRender.replace self.options.products.slice(0,2)
					can.$('li.inventory-page:first').addClass 'active'
				else
					Helpers.showMessage 'error', response.errorMessage
			, (xhr) ->
				if xhr.status is 403
					Helpers.showMessage 'error', 'Su usuario no tiene privilegios para acceder a esta informacion'
				else
					Helpers.showMessage 'error', 'Error consiguiendo detalles de venta, favor intentar de nuevo'

		destroy : ->
			can.Control.prototype.destroy.call @
