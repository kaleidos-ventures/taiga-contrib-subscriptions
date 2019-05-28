moduleName = 'subscriptions'

window.taigaContribPlugins = [] if !window.taigaContribPlugins

window.taigaContribPlugins.push({
<<<<<<< HEAD
        type: 'userSettings',
        template: 'compile-modules/taiga-contrib-subscriptions/partials/taiga-app.html',
        name: 'Taiga App',
        slug: 'taiga-app',
        module: moduleName,
        userMenu: true,
        headerMenu: true,
        authenticated: true,
    },
    {
        type: 'userSettings',
        template: 'compile-modules/taiga-contrib-subscriptions/partials/subscriptions.html',
        name: 'Paid Plans',
        slug: 'subscriptions',
        module: moduleName,
        userMenu: true,
        headerMenu: true,
        authenticated: true,
        headerHtml: (user) ->
            if user.get('max_private_projects') == 1
                return "<div class='upgrade-header-button'>Upgrade</div>"
            return ""
=======
    type: 'userSettings',
    template: 'compile-modules/taiga-contrib-subscriptions/subscriptions.html',
    name: 'Paid Plans',
    slug: 'subscriptions',
    module: moduleName,
    userMenu: true,
    headerMenu: true,
    authenticated: true
>>>>>>> Refactoring
})

angular.module(moduleName, [])
