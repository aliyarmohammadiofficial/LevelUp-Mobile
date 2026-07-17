import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/mascot.dart';

import '../../../dashboard/presentation/widgets/dashboard_tip_card.dart';
import '../../../workout/presentation/widgets/routine_tab_bar.dart';

import '../../domain/entities/fasting_entities.dart';
import '../providers/fasting_providers.dart';
import '../widgets/fasting_history_tile.dart';
import '../widgets/fasting_plan_card.dart';
import '../widgets/fasting_timer_ring.dart';



class FastingScreen extends ConsumerStatefulWidget {

  const FastingScreen({
    super.key,
  });


  @override
  ConsumerState<FastingScreen> createState() =>
      _FastingScreenState();

}



class _FastingScreenState
    extends ConsumerState<FastingScreen> {


  int _tabIndex = 0;


  static const tabs = [
    'Timer',
    'History',
  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Fasting',
        ),
      ),


      body: SafeArea(

        child: Padding(

          padding: AppSpacing.screenPadding,

          child: Column(

            children: [


              RoutineTabBar(

                tabs: tabs,

                selectedIndex: _tabIndex,


                onSelected: (index){

                  setState(() {

                    _tabIndex = index;

                  });

                },

              ),


              const SizedBox(
                height: AppSpacing.lg,
              ),


              Expanded(

                child: _tabIndex == 0

                    ? const _TimerTab()

                    : const _HistoryTab(),

              )

            ],

          ),

        ),

      ),

    );

  }

}








class _TimerTab extends ConsumerWidget {


  const _TimerTab();



  Future<void> _showPlanPicker(
      BuildContext context,
      WidgetRef ref,
      ) async {


    final plans =
        ref.read(fastingPlansProvider);



    if(plans.isEmpty) return;



    var selected = plans.first;



    final result =
        await showModalBottomSheet<FastingPlan>(

          context: context,


          backgroundColor:
              AppColors.surface,


          shape:
              const RoundedRectangleBorder(

                borderRadius:
                BorderRadius.vertical(
                  top: Radius.circular(
                    AppRadius.xl,
                  ),
                ),

              ),



          builder: (context){


            return StatefulBuilder(


              builder:(context,setState){


                return Padding(

                  padding:
                  const EdgeInsets.all(
                    AppSpacing.xl,
                  ),



                  child: Column(


                    mainAxisSize:
                    MainAxisSize.min,



                    children: [


                      Text(

                        'Choose a Plan',

                        style:
                        Theme.of(context)
                            .textTheme
                            .titleLarge,

                      ),



                      const SizedBox(
                        height:
                        AppSpacing.lg,
                      ),



                      ...plans.map(

                            (plan)=>

                            Padding(

                              padding:
                              const EdgeInsets.only(
                                bottom:
                                AppSpacing.sm,
                              ),


                              child:
                              FastingPlanCard(

                                plan: plan,


                                isSelected:
                                selected.id ==
                                    plan.id,


                                onTap: (){

                                  setState((){

                                    selected =
                                        plan;

                                  });

                                },

                              ),

                            ),

                      ),



                      const SizedBox(
                        height:
                        AppSpacing.md,
                      ),



                      AppButton(

                        label:
                        'Start Fast',


                        onPressed: (){

                          Navigator.pop(
                            context,
                            selected,
                          );

                        },

                      ),

                    ],

                  ),

                );


              },

            );


          },

        );



    if(result != null){

      await ref
          .read(fastingRepositoryProvider)
          .startFast(result);


      ref.invalidate(
        fastingSessionProvider,
      );

    }

  }







  Future<void> _endFast(
      BuildContext context,
      WidgetRef ref,
      ) async {



    final confirm =
        await showDialog<bool>(


          context: context,


          builder:(context)=>AlertDialog(

            title:
            const Text(
              'End fast?',
            ),


            content:
            const Text(
              'Are you sure you want to end this fast early?',
            ),


            actions:[


              TextButton(

                onPressed: ()=>Navigator.pop(
                    context,
                    false
                ),

                child:
                const Text(
                  'Cancel',
                ),

              ),



              TextButton(

                onPressed: ()=>Navigator.pop(
                    context,
                    true
                ),

                child:
                const Text(
                  'End Fast',
                ),

              ),

            ],

          ),

        );



    if(confirm == true){

      await ref
          .read(fastingRepositoryProvider)
          .endFastEarly();



      ref.invalidate(
        fastingSessionProvider,
      );

    }

  }







  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {


    final session =
        ref.watch(fastingSessionProvider);


    return session.when(


      loading: ()=>const AppLoadingIndicator(),



      error:(e,s)=>

          const Center(

            child:
            Mascot(

              pose:
              MascotPose.sad,

              size:
              96,

            ),

          ),




      data:(fast)=>


          fast == null

              ? _empty(context,ref)

              : _active(
              context,
              ref,
              fast
          ),

    );

  }






  Widget _empty(
      BuildContext context,
      WidgetRef ref,
      ){


    return Center(

      child:Column(

        mainAxisSize:
        MainAxisSize.min,


        children:[


          const Mascot(

            pose:
            MascotPose.sleepy,

            size:
            96,

          ),



          const SizedBox(
            height:
            AppSpacing.md,
          ),



          Text(

            'No active fast',

            style:
            Theme.of(context)
                .textTheme
                .titleMedium,

          ),



          const SizedBox(
            height:
            AppSpacing.lg,
          ),



          AppButton(

            label:
            'Start Fast',


            onPressed: ()=>
                _showPlanPicker(
                    context,
                    ref
                ),

          ),

        ],

      ),

    );


  }







  Widget _active(
      BuildContext context,
      WidgetRef ref,
      FastingSession session,
      ){


    final eating =
        session.state ==
            FastingSessionState.eatingWindow;



    return ListView(

      children:[


        Center(

          child:
          FastingTimerRing(

            session:
            session,

            now:
            DateTime.now(),

          ),

        ),



        const SizedBox(
          height:
          AppSpacing.xl,
        ),



        AppButton(

          label:
          eating
              ?
          'Start Next Fast'
              :
          'End Fast Early',



          onPressed: ()=> eating

              ? _showPlanPicker(
              context,
              ref
          )

              : _endFast(
              context,
              ref
          ),

        ),



        const SizedBox(
          height:
          AppSpacing.lg,
        ),



        const DashboardTipCard(

          tip:
          'Stay hydrated during fasting.',

        ),


      ],

    );


  }


}







class _HistoryTab extends ConsumerWidget {


  const _HistoryTab();



  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ){


    final history =
        ref.watch(
            fastingHistoryProvider
        );



    return history.when(

      loading: ()=>const AppLoadingIndicator(),


      error:(e,s)=>
      const Center(
        child:
        Text(
          'Could not load history',
        ),
      ),



      data:(items)=>


          items.isEmpty

              ? const Center(

            child:
            Mascot(

              pose:
              MascotPose.sleepy,

              size:
              96,

            ),

          )


              :

          ListView.builder(

            itemCount:
            items.length,


            itemBuilder:(context,index)=>

                FastingHistoryTile(

                  entry:
                  items[index],

                ),

          ),

    );


  }

}
