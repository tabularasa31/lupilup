import { Session } from '@supabase/supabase-js';
import { useEffect, useState } from 'react';

import { supabase } from '@/lib/supabase';

type AuthState = {
  session: Session | null;
  isFirstTime: boolean;
  loading: boolean;
};

export function useAuth(): AuthState {
  const [session, setSession] = useState<Session | null>(null);
  const [isFirstTime, setIsFirstTime] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, newSession) => {
      setSession(newSession);

      if (event === 'SIGNED_IN' && newSession) {
        const { data } = await supabase
          .from('user_settings')
          .select('user_id')
          .eq('user_id', newSession.user.id)
          .maybeSingle();

        setIsFirstTime(!data);
      }

      if (event === 'SIGNED_OUT') {
        setIsFirstTime(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  return { session, isFirstTime, loading };
}
