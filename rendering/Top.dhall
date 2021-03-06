let Prelude = ../Prelude.dhall

let JSON = Prelude.JSON

let Map = Prelude.Map

let types = ../types.dhall

let Job/toJSON = ./Job.dhall

let GitSubmoduleStrategy/toJSON = ./GitSubmoduleStrategy.dhall

let dropNones = ../utils/dropNones.dhall

let stringsArray
    : List Text → JSON.Type
    = λ(xs : List Text) →
        JSON.array (Prelude.List.map Text JSON.Type JSON.string xs)

let Top/toJSON
    : types.Top.Type → JSON.Type
    = λ(top : types.Top.Type) →
        let jobs
            : Map.Type Text JSON.Type
            = Prelude.Map.map Text types.Job.Type JSON.Type Job/toJSON top.jobs

        let others
            : Map.Type Text JSON.Type
            = dropNones
                Text
                JSON.Type
                ( toMap
                    { stages =
                        Prelude.Optional.map
                          (List Text)
                          JSON.Type
                          stringsArray
                          top.stages
                    , variables = Some
                        ( JSON.object
                            ( toMap
                                { GIT_SUBMODULE_STRATEGY =
                                    GitSubmoduleStrategy/toJSON
                                      top.gitSubmoduleStrategy
                                }
                            )
                        )
                    }
                )

        let everything
            : Map.Type Text JSON.Type
            = jobs # others

        in  JSON.object everything

in  Top/toJSON
