package com.example.weather_nsu

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.AsyncTask
import android.os.Debug
import android.widget.RemoteViews
import android.widget.TextView
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlinx.coroutines.Delay
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.jsoup.Jsoup
import java.lang.Exception
import java.net.URL
import java.util.concurrent.Future
import kotlin.concurrent.thread


class HomeWidgetExampleProvider : HomeWidgetProvider() {

    class MyTask(var widgetId: Int, var appWidgetManager: AppWidgetManager, var views: RemoteViews) : AsyncTask<Void, Void, String>() {
        override fun doInBackground(vararg params: Void?): String {
            try {
                var time = (System.currentTimeMillis()/1000).toInt();
                var doc = URL("http://weather.nsu.ru/weather.xml?std=three").readText()
                var pattern = Regex("""(?<=\>)(.*?)(?=\<\/current\>)""");
                var rawTemp = pattern.find(doc)?.value;
                var temp = rawTemp.toString();
                updateWeather(temp);
            }
            catch (e: Exception)
            {
            }
            return "";
        }
        fun updateWeather(temp: String)
        {
            views.setTextViewText(R.id.widget_title, "$temp°"
                    ?: "No Message Set");

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.example_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                val message = widgetData.getString("message", null)
                var title = widgetData.getString("title", null)
            }

            appWidgetManager.updateAppWidget(widgetId, views)

            MyTask(widgetId, appWidgetManager, views).execute();
        }
    }
}