@app.controller 'ContractController', [
    '$scope'
    ($scope) ->
        $scope.test = 15
        $scope.contract =
            deal:
                id: 1
                name: 'Test Deal 1'
            advertiser:
                id: 1
                name: 'Procter & Gamble'
            agency:
                id: 1
                name: 'Procter & Gamble'
            agency_holding:
                id: 1
                name: 'Carat'
            desc: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Amet consectetur explicabo facere quam qui! Aliquid animi deserunt ducimus expedita illo minus nihil quae repellat repellendus reprehenderit, sed vero. A adipisci aliquam aspernatur, assumenda commodi consequuntur cupiditate delectus, distinctio dolor dolorem earum eius enim eos, excepturi exercitationem explicabo maiores natus nemo odio officia optio pariatur possimus saepe sapiente sequi tempora tempore. Aliquam hic id incidunt numquam omnis sint voluptate! Dicta dolorum enim nemo nesciunt optio perferendis perspiciatis quia recusandae repudiandae tenetur. Assumenda dolorum eaque illo impedit ipsa laboriosam libero magni necessitatibus nihil quibusdam. Accusantium cumque debitis eligendi minus nam reiciendis similique totam vel veniam voluptate. Deserunt doloremque expedita laborum ullam! Animi aperiam culpa dolorum, eaque eos error, hic magnam maxime odio optio repellendus repudiandae sunt suscipit temporibus, totam vero vitae. Accusantium aspernatur cumque cupiditate debitis dolor esse illum impedit incidunt iste itaque laborum minima nihil qui quos, tempore temporibus ut vero voluptatibus. Autem consequuntur eius explicabo ipsa magnam quibusdam quis temporibus. Assumenda, ea earum eligendi, error itaque labore molestias, nemo nesciunt nisi omnis quae repellendus suscipit tempore temporibus velit! Ad aperiam architecto asperiores corporis dicta error facere fuga fugiat labore molestiae nihil perferendis quia ratione repudiandae, totam, vel veritatis voluptas voluptatem!'
            auto_notifications: true
]
