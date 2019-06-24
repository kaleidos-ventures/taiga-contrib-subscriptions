###
# Copyright (C) 2014-2019 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: subscriptions.controller.coffee
###

module = angular.module('subscriptions')

class SubscriptionsController
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "tgLoader",
        "lightboxService",
        "$translatePartialLoader",
        "$translate",
        "ContribPaymentsService",
        "$tgAnalytics",
        "$tgConfirm",
        "$tgConfig",
        "tgCurrentUserService",
        "tgUserService",
        "$tgAuth",
        "$rootScope"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader, @lightboxService, @translatePartialLoader,
                  @translate, @paymentsService, @analytics, @confirm, @config, @currentUserService, @userService,
                  @authService, @rootscope) ->
        @translatePartialLoader.addPart('taiga-contrib-subscriptions')

    init: ->
        @._loadMetas()
        @._loadPlans()
        @.invalidPlan = null
        @.user = @currentUserService.getUser()
        @.userService.getContacts(@.user.get('id')).then (contacts) =>
            @.userContactsById = Immutable.fromJS({})
            contacts.forEach (contact) =>
                @.userContactsById = @.userContactsById.set(contact.get('id').toString(), contact)

        @.viewingMembers = false

        @rootscope.$on("subscription:changed", @._loadPlans)

        Object.defineProperty @, "myPlan", {
            get: () => @.subscriptionsService.myPlan
        }

        Object.defineProperty @, "publicPlans", {
            get: () => @.subscriptionsService.publicPlans
        }

        Object.defineProperty @, "perSeatPlan", {
            get: () => @.subscriptionsService.perSeatPlan
        }

        Object.defineProperty @, "currentPlanCategory", {
            get: () => @.getPlanCategory(@.myPlan)
        }

        Object.defineProperty @, "currentPlanImage", {
            get: () =>
                if @.currentPlanCategory == 'free'
                    return 'seed'
                else if @.currentPlanCategory == 'premium'
                    return 'leaf'
                else
                    planName = @.myPlan.current_plan.name.toLowerCase()
                    if _.includes(['leaf', 'root', 'seed', 'sprout', 'tree'], planName)
                        return planName
                return 'custom'
        }

    getPlanCategory: (plan) ->
        if !plan
            return 'free'
        else if !plan.current_plan
            return 'free'
        else if plan.current_plan.id == "per-seat-free"
            return 'free'
        else if plan.current_plan.id_month == "per-seat-month"
            return 'premium'
        else if plan.current_plan.id_year == "per-seat-year"
            return 'premium'
        else
            return 'custom'

    _loadMetas: () ->
        sectionTitle = @translate.instant("SUBSCRIPTIONS.TITLE")
        description = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")
        @.sectionName = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")

        @appMetaService.setAll(sectionTitle, description)

    _loadPlans: =>
        @tgLoader.start()

        promise1 = @subscriptionsService.getMyPerSeatPlan()
        promise2 = @subscriptionsService.loadUserPlan()
        promise3 = @subscriptionsService.fetchPublicPlans()
        Promise.all([promise1, promise2, promise3]).then () =>
            for plan in @.publicPlans
                if plan.id == "per-seat-free"
                    @.publicPlanFree = plan
                else if plan.id_month == "per-seat-month"
                    @.publicPlanPerSeat = plan
            if @.perSeatPlan.notify_limit == null
                @.notify = {
                    active: false,
                    when: 'always',
                    limit: '1'
                }
            else if @.perSeatPlan.notify_limit == 0
                @.notify = {
                    active: true,
                    when: 'always',
                    limit: '1'
                }
            else
                @.notify = {
                    active: true,
                    when: 'on-limit',
                    limit: @.perSeatPlan.notify_limit
                }
            @tgLoader.pageLoaded()


    userProjectsList: (projects, user) ->
        @.userProjectsLb = Immutable.fromJS({})
                                    .set('user', user)
                                    .set('projects', projects)
                                    .set('richProjects', projects.map((projectId) => @currentUserService.projectsById.get(projectId.toString())))
        @lightboxService.open('tg-lb-user-projects')

    changePaymentsData: () ->
        description = @translate.instant("SUBSCRIPTIONS.PAYMENT_HISTORY.CHANGE_DATA")
        @paymentsService.changeData({
            name: 'Taiga',
            description: description
            onSuccess: @._onSuccessChangePaymentsData.bind(this)
        })

    contactUs: () ->
        @.openLightbox('tg-lb-contact-us')

    removeUserFromMyProjects: (user) ->
        @.deletingUser = user
        @lightboxService.open('tg-lb-confirm-member-remove')

    confirmRemoveUserFromMyProjects: (userId) =>
        @tgLoader.start()

        promise = @subscriptionsService.removeUserFromMyProjects(userId)
        promise.then () =>
            @lightboxService.closeAll()

            message = @translate.instant("SUBSCRIPTIONS.REMOVE_USER_LB.SUCCESS")
            @confirm.notify('success', message, '', 5000)

            @subscriptionsService.getMyPerSeatPlan().then () =>
                @tgLoader.pageLoaded()

    seeBillingDetails: () ->
        secure_id = @.myPlan.secure_id
        @paymentsService.seeBilling({
            secure_id: secure_id
        })

    _onSuccessChangePaymentsData: (data) ->
        @tgLoader.start()

        @subscriptionsService.selectMyPlan(data).then(@._onSuccessChangedData.bind(this))

    _onSuccessChangedData: () ->
        message = @translate.instant("SUBSCRIPTIONS.PAYMENT_HISTORY.CHANGE_DATA_SUCCESS")

        @confirm.notify('success', message, '', 5000)

        promise = @subscriptionsService.fetchPublicPlans()
        promise.then () =>
            @tgLoader.pageLoaded()

    openLightbox: (selector) ->
        @lightboxService.open(selector)

    showPlans: () ->
        @lightboxService.open('.lightbox-plans')

    selectPlanInterval: (plan) ->
        @.subscribePlan = plan
        @.changeMode = 'update'
        @.openLightbox('tg-lb-change-subscription')

    cancelPlan: () ->
        @.changeMode = 'cancel'
        @.changeToPublicPlanFree()

    downgradePlan: () ->
        @.changeMode = 'downgrade'
        @.changeToPublicPlanFree()

    changeToPublicPlanFree: () ->
        @.subscribePlan = @.publicPlanFree
        if !@.publicPlanFree.is_applicable
            @.openLightbox('tg-lb-invalid-plan')
            return
        @.openLightbox('tg-lb-change-subscription')

    changePlan: (plan, mode, month=true) ->
        @.loadingPayments = true

        if plan.id
            planId = plan.id
            amount = plan.amount * (@.perSeatPlan.members.length || 1)
        else if month
            planId = plan.id_month
            amount = plan.amount_month * (@.perSeatPlan.members.length || 1)
        else
            planId = plan.id_year
            amount = plan.amount_year * (@.perSeatPlan.members.length || 1)
        name = plan.name
        currency = plan.currency

        @analytics.ecAddToCart(planId, name, amount)
        @analytics.ecConfirmChange(planId, name, amount)

        if @.myPlan?.current_plan && @.myPlan.customer_id?
            plan = {
                'plan_id': planId,
                'quantity': (@.perSeatPlan.members.length || 1)
            }
            @._onSuccessBuyPlan(plan, amount, currency, mode)
        else
            @paymentsService.start({
                description: name,
                amount: amount,
                onLoad: () => @.loadingPayments = false
                onSuccess: (plan) =>
                    @analytics.ecPurchase(planId, name, amount)
                    @._onSuccessBuyPlan(plan, amount, currency, mode)
                planId: planId,
                currency: currency,
                email: @.user.get('email'),
                full_name: @.user.get('full_name')
            })

    _onSuccessBuyPlan: (plan, amount, currency, mode) ->
        @lightboxService.closeAll()
        @tgLoader.start()

        if !@.myPlan || (!@.myPlan.current_plan?.amount_month && !@.myPlan.current_plan?.amount_year)
            google_conversion_id = @config.get("google_adwords_conversion_id")
            google_conversion_label = @config.get("google_adwords_conversion_label")

            if google_conversion_id && google_conversion_label
                window.google_trackConversion({
                    google_conversion_id : google_conversion_id
                    google_conversion_language : "en",
                    google_conversion_format : "3",
                    google_conversion_color : "ffffff",
                    google_conversion_label : google_conversion_label
                    google_remarketing_only : false
                    google_conversion_value: amount
                    google_conversion_currency: currency.toUpperCase()
                })


        @subscriptionsService.selectMyPlan(plan).then () =>
            @._onSuccessSelectPlan()
        .catch (e) =>
            @._onFailedSelectPlan(e.data.detail)

    _onSuccessSelectPlan: () ->
        message = @translate.instant("SUBSCRIPTIONS.SELECT_PLAN.SUCCESS")
        @confirm.notify('success', message, '', 5000)
        @authService.refresh()

        @._loadPlans()

    _onFailedSelectPlan: (msg) ->
        @confirm.notify("error", msg)
        @authService.refresh()

        @._loadPlans()

    setNotifyActive: () ->
        @.notify.when = 'always'
        @.notify.limit = 0

    setNotifyWhen: (whenNotify) ->
        @.notify.limit = 1

    showSaveLimit: () ->
        limit = null
        if !@.notify.active
            limit = null
        else if @.notify.when == 'always'
            limit = 0
        else if @.notify.when == 'on-limit'
            limit = @.notify.limit
        else
            return false

        if @.perSeatPlan.notify_limit == limit
            return false
        return true

    saveNotifyLimit: () =>
        limit = null
        if !@.notify.active
            limit = null
        else if @.notify.when == 'always'
            limit = 0
        else if @.notify.when == 'on-limit'
            limit = @.notify.limit
        else
            return

        if @.perSeatPlan.notify_limit == limit
            return

        promise = @subscriptionsService.setMyPerSeatPlanNotifyLimit(limit)
        promise.then () =>
            @subscriptionsService.getMyPerSeatPlan()
            message = @translate.instant("SUBSCRIPTIONS.NOTIFY_LIMIT.SUCCESS")
            @confirm.notify('success', message, '', 5000)

        promise.catch () =>
            @confirm.notify('error')


module.controller("ContribSubscriptionsController", SubscriptionsController)
