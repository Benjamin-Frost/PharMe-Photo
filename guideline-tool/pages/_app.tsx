import '../styles/globals.css';
import type { AppProps } from 'next/app';

import { NavBar } from '../components/NavBar';

function GuidelineTool({ Component, pageProps }: AppProps): JSX.Element {
    return (
        <>
            <NavBar />
            <Component {...pageProps} />
        </>
    );
}

export default GuidelineTool;
