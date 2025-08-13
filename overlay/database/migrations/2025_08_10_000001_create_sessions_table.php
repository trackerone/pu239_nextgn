public function up(): void
{
    // Kør kun hvis vi bruger database-sessions
    if (config('session.driver') !== 'database') {
        return;
    }

    if (\Illuminate\Support\Facades\Schema::hasTable('sessions')) {
        return; // intet at gøre
    }

    Schema::create('sessions', function (Blueprint $table) {
        $table->string('id')->primary();
        $table->foreignId('user_id')->nullable()->index();
        $table->string('ip_address', 45)->nullable();
        $table->text('user_agent')->nullable();
        $table->text('payload');
        $table->integer('last_activity')->index();
    });
}

public function down(): void
{
    if (\Illuminate\Support\Facades\Schema::hasTable('sessions')) {
        Schema::drop('sessions');
    }
}
